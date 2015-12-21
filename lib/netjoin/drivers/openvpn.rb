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

    def self.install_on_aws(node, manifest)
      ip = node.public_ip_address
      user = node.ssh_user ? node.ssh_user : 'ec2-user'

      other_routes = []
      Netjoin::Models::Topologies.get_all_server_nodes_except(node.name).each do |n|
        other_routes << Netjoin::Models::Nodes.new(name: n)
      end

      psk = manifest.driver['psk']

      conf = generate_conf
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

      other_routes = []
      master_node = nil
      Netjoin::Models::Topologies.get_all_server_nodes_except(node.name).each do |n|
        _n = Netjoin::Models::Nodes.new(name: n)
        if _n.type == 'aws'
          master_node = _n
        end
        other_routes << _n if _n.name != node.name && _n.type != 'bare-metal'
      end

      psk = manifest.driver['psk']

      conf = generate_conf
      conf << "secret /etc/openvpn/#{File.basename(psk)}\n"
      conf << "remote #{master_node.public_ip_address}\n"
      other_routes.each do |other_node|
        other_node.networks.each do |network|
          n = Netjoin::Models::Networks.new(name: network)
          conf << "route #{n.network_ip_address} 255.255.255.0\n"
        end
      end

      File.open("./tmpconf", "w") do |f|
        f.write conf
      end

      p node.ssh_ip_address
      p node.ssh_user
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
