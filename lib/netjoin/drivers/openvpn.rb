# -*- coding: utf-8 -*-

require 'net/ssh'
require 'net/scp'
require 'net/ssh/proxy/command'
require 'ipaddr'

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

    def self.install_on_aws(node, manifest)
      ip = node.public_ip_address
      user = node.ssh_user ? node.ssh_user : 'ec2-user'

      other_routes = []

      psk = manifest.driver['psk']

      conf = generate_conf
      conf << "secret /etc/openvpn/#{File.basename(psk)}\n"

      File.open("./tmpconf", "w") do |f|
        f.write conf
      end

      Net::SCP.start(ip, user, :keys => [node.ssh_privatekey]) do |scp|
        scp.upload!(psk, "#{File.basename(psk)}")
        scp.upload!("./tmpconf", "tmpconf")
      end

      Net::SSH.start(ip, user, :keys => [node.ssh_privatekey]) do |ssh|
        commands = []
        commands << "sudo yum -y install epel-release"
        commands << "sudo yum -y install openvpn"

        commands << "sudo curl -O http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/openvswitch-2.4.0-1.x86_64.rpm"
        commands << "sudo yum -y localinstall openvswitch-2.4.0-1.x86_64.rpm"

        commands << "sudo mv #{users_dir_path(user)}/#{File.basename(psk)} /etc/openvpn"
        commands << "sudo mv #{users_dir_path(user)}/tmpconf /etc/openvpn/vpn.conf"

        commands << "sudo service openvpn stop || :"
        commands << "sudo service openvpn start"
        commands << "sudo service openvswitch start"

        commands << "sudo ovs-vsctl --if-exists del-br brtun"
        commands << "sudo ovs-vsctl --may-exist add-br brtun"
        commands << "sudo ovs-vsctl --if-exists del-port brtun tap0"
        commands << "sudo ovs-vsctl --may-exist add-port brtun tap0"
        commands << "sudo ip link set brtun up"
        commands << "sudo ip link set tap0 up"
        ssh_exec(ssh, commands)
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

      psk = manifest.driver['psk']

      conf = generate_conf
      conf << "resolv-retry infinite\n"
      conf << "secret /etc/openvpn/#{File.basename(psk)}\n"

      manifest.nodes.each do |n|
        next if n == node.name
        _n = Netjoin::Models::Nodes.new(name: n)
        if _n.type == 'aws'
          conf << "remote #{_n.public_ip_address}\n"
        end
      end

      File.open("./tmpconf", "w") do |f|
        f.write conf
      end

      Net::SCP.start(node.ssh_ip_address, node.ssh_user, ssh_options) do |scp|
        scp.upload!(psk, "#{File.basename(psk)}")
        scp.upload!("./tmpconf", "tmpconf")
      end

      Net::SSH.start(node.ssh_ip_address, node.ssh_user, ssh_options) do |ssh|
        commands = []
        commands << "yum -y install epel-release || :"
        commands << "yum -y install openvpn || :"

        commands << "sudo mv #{users_dir_path(node.ssh_user)}/#{File.basename(psk)} /etc/openvpn"
        commands << "sudo mv #{users_dir_path(node.ssh_user)}/tmpconf /etc/openvpn/vpn.conf"

        commands << "service openvpn stop || :"
        commands << "service openvpn start"

        commands << "sudo ovs-vsctl --if-exists del-br brtun"
        commands << "sudo ovs-vsctl --may-exist add-br brtun"
        commands << "sudo ovs-vsctl --if-exists del-port brtun tap0"
        commands << "sudo ovs-vsctl --may-exist add-port brtun tap0"
        commands << "sudo ip link set brtun up"
        commands << "sudo ip link set tap0 up"
        ssh_exec(ssh, commands)
      end
    end

    private

    def self.users_dir_path(user)
      if user == 'root'
        return '/root'
      end
      "/home/#{user}"
    end

    def self.generate_conf
      str = ""
      str << "float\n"
      str << "port 1194\n"
      str << "dev tap0\n"
      str << "persist-tun\n"
      str << "persist-key\n"
      str << "comp-lzo\n"
      str << "user nobody\n"
      str << "group nobody\n"
      str << "log vpn.log\n"
      str << "verb 3\n"
      str
    end
  end
end
