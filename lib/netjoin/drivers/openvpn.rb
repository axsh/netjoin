# -*- coding: utf-8 -*-

require 'net/ssh'
require 'net/scp'
require 'net/ssh/proxy/command'

module Netjoin::Drivers
  module Openvpn
    extend Netjoin::Helpers::Logger

    def self.install(node, network)
      case node.type
      when 'kvm'
        install_on_kvm(node, network)
      when 'aws'
        install_on_aws(node, network)
      else
        error "unknown node type"
      end
    end

    def self.install_on_aws(node, network)
      ip = node.public_ip_address
      user = 'root'

      Net::SSH.start(ip, user, :keys => [node.privatekey_file_name]) do |ssh|
        info ssh.exec!("yum -y install epel-release")
        info ssh.exec!("yum -y install openvpn")

        conf = generate_conf
        conf << "persist-remote-ip\n"
        conf << "ifconfig 10.8.0.1 10.8.0.2\n"
        conf << "secret /etc/openvpn/#{File.basename(network.psk)}"

        info ssh.exec!("echo \"#{conf}\" > /etc/openvpn/vpn.conf")
        info ssh.exec!("service openvpn stop || :")
        info ssh.exec!("service openvpn start")
      end
    end

    def self.install_on_kvm(node, network)
      parent = Netjoin::Models::Nodes.new(name: node.parent)
      proxy = Net::SSH::Proxy::Command.new("
        ssh #{parent.ssh_ip_address} \
          -l #{parent.ssh_user} \
          -o StrictHostKeyChecking=no \
          -o UserKnownHostsFile=/dev/null \
          -W %h:%p -i #{parent.ssh_privatekey}")

      ssh_options = {}
      ssh_options.merge!(:proxy => proxy)
      ssh_options.merge!(:keys => [node.ssh_privatekey])

      master_node = nil
      network.server_nodes.each do |n|
        _n = Netjoin::Models::Nodes.new(name: n)
        if _n.type == 'aws'
          master_node = _n
        end
      end

      Net::SSH.start(node.ssh_ip_address, node.ssh_user, ssh_options) do |ssh|
        info ssh.exec!("echo \"#{File.read(network.psk)}\" > /etc/openvpn/#{File.basename(network.psk)}")

        conf = generate_conf
        conf << "remote #{master_node.public_ip_address}\n"
        conf << "ifconfig 10.8.0.2 10.8.0.1\n"
        conf << "secret /etc/openvpn/#{File.basename(network.psk)}"

        info ssh.exec!("echo \"#{conf}\" > /etc/openvpn/vpn.conf")

        info ssh.exec!("yum -y install epel-release || :")
        info ssh.exec!("yum -y install openvpn || :")
        info ssh.exec!("ls -la /etc/openvpn || :")
        info ssh.exec!("service openvpn stop || :")
        info ssh.exec!("service openvpn start")
      end
    end

    private

    def self.generate_conf
      str = ""
      str << "float\n"
      str << "port 1194\n"
      str << "dev tun\n"
      str << "persist-tun\n"
      str << "persist-local-ip\n"
      str << "comp-lzo\n"
      str << "user nobody\n"
      str << "group nobody\n"
      str << "log vpn.log\n"
      str << "verb 3\n"
      str
    end
  end
end
