# -*- coding: utf-8 -*-

require 'net/ssh'
require 'net/scp'
require 'net/ssh/proxy/command'

module Netjoin::Drivers
  module Openvpn
    extend Netjoin::Helpers::Logger

    def self.install(node, manifest)
      case node.type
      when 'kvm'
        install_on_kvm(node, manifest)
      when 'aws'
        install_on_aws(node, manifest)
      else
        error "unknown node type"
      end
    end

    def self.ssh_exec(ssh, command)
      ssh.open_channel do |ch|
        ch.request_pty do |ch, success|
          info command
          ch.exec command do |ch, success|
            ch.on_data do |ch, data|
              info data
            end
          end
        end
      end
    end

    def self.install_on_aws(node, manifest)
      ip = node.public_ip_address
      user = node.ssh_user ? node.ssh_user : 'ec2-user'

      other_routes = []
      manifest.server_nodes.each do |n|
        next if n == node.name
        _n = Netjoin::Models::Nodes.new(name: n)
        other_routes << _n if _n.name != node.name && _n.type != 'bare-metal'
      end

      psk = manifest.driver['psk']

      conf = generate_conf
      conf << "persist-remote-ip\n"
      conf << "ifconfig 10.8.0.1 10.8.0.2\n"
      conf << "secret /etc/openvpn/#{File.basename(psk)}\n"
      other_routes.each do |other_node|
        other_node.networks.each do |network|
          n = Netjoin::Models::Networks.new(name: network)
          conf << "route #{n.network_ip_address} 255.255.255.0\n"
        end
      end

      File.open("./tmpconf", "w") do |f|
        f.write conf
      end

      Net::SCP.start(ip, user, :keys => [node.privatekey_file_name]) do |scp|
        scp.upload!(psk, "#{File.basename(psk)}")
        scp.upload!("./tmpconf", "tmpconf")
      end

      Net::SSH.start(ip, user, :keys => [node.privatekey_file_name]) do |ssh|
        ssh_exec(ssh, "sudo yum -y install epel-release")
        ssh_exec(ssh, "sudo yum -y install openvpn")

        ssh_exec(ssh, "sudo mv ~/#{File.basename(psk)} /etc/openvpn")
        ssh_exec(ssh, "sudo mv ~/tmpconf /etc/openvpn/vpn.conf")


        ssh_exec(ssh, "sudo service openvpn stop || :")
        ssh_exec(ssh, "sudo service openvpn start")
      end
    end

    def self.install_on_kvm(node, manifest)
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

      other_routes = []
      master_node = nil
      manifest.server_nodes.each do |n|
        next if n == node.name
        _n = Netjoin::Models::Nodes.new(name: n)
        if _n.type == 'aws'
          master_node = _n
        end
        other_routes << _n if _n.name != node.name && _n.type != 'bare-metal'
      end

      Net::SSH.start(node.ssh_ip_address, node.ssh_user, ssh_options) do |ssh|
        psk = manifest.driver['psk']
        info ssh.exec!("echo \"#{File.read(psk)}\" > /etc/openvpn/#{File.basename(psk)}")

        conf = generate_conf
        conf << "remote #{master_node.public_ip_address}\n"
        conf << "ifconfig 10.8.0.2 10.8.0.1\n"
        conf << "secret /etc/openvpn/#{File.basename(psk)}\n"
        other_routes.each do |other_node|
          other_node.networks.each do |network|
            n = Netjoin::Models::Networks.new(name: network)
            conf << "route #{n.network_ip_address} 255.255.255.0\n"
          end
        end

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
