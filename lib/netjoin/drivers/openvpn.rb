# -*- coding: utf-8 -*-

require 'net/ssh'
require 'net/scp'

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
      tmp_config_file = "./tmp_config.conf"

      File.open(tmp_config_file, "w") do |f|
        f.puts("persist-remote-ip")
        f.puts("dev tun")
        f.puts("persist-tun")
        f.puts("persist-local-ip")
        f.puts("comp-lzo")
        f.puts("user nobody")
        f.puts("group nobody")
        f.puts("log vpn.log")
        f.puts("verb 3")
        # f.puts("secret #{File.basename(network.psk)}")
      end

      ip = node.public_ip_address
      user = 'root'

      Net::SSH.start(ip, user, :keys => [node.privatekey_file_name]) do |ssh|
        p ssh.exec!("yum -y install epel-release")
        p ssh.exec!("yum -y install openvpn")
      end

      Net::SCP.upload!(ip, user, tmp_config_file, "/etc/openvpn", :ssh => {:keys => [node.privatekey_file_name]})

      Net::SSH.start(ip, user, :keys => [node.privatekey_file_name]) do |ssh|
        p ssh.exec!("service openvpn start")
      end
    end

    def self.install_on_kvm(node, network)
      tmp_config_file = "./tmp_config.conf"

      File.open(tmp_config_file, "w") do |f|
        f.puts("persist-remote-ip")
        f.puts("dev tun")
        f.puts("persist-tun")
        f.puts("persist-local-ip")
        f.puts("comp-lzo")
        f.puts("user nobody")
        f.puts("group nobody")
        f.puts("log vpn.log")
        f.puts("verb 3")
        # f.puts("secret #{File.basename(network.psk)}")
      end

      if node.ssh_from
        ip = node.ssh_from['ssh_ip_address']
        user = node.ssh_from['ssh_user']
        password = node.ssh_from['ssh_password']

        Net::SCP.upload!(ip, user, tmp_config_file, "/tmp", :ssh => {:password => password})
        Net::SSH.start(ip, user, :password => password) do |ssh|
          _i = node.ssh_ip_address
          _u = node.ssh_user
          p ssh.exec!("ssh -i /root/.ssh/id_rsa #{_u}@#{_i} yum -y install epel-release")
          p ssh.exec!("ssh -i /root/.ssh/id_rsa #{_u}@#{_i} yum -y install openvpn")
          p ssh.exec!("scp -i /root/.ssh/id_rsa /tmp/tmp_config.conf #{_u}@#{_i}:/etc/openvpn")
          p ssh.exec!("ssh -i /root/.ssh/id_rsa #{_u}@#{_i} service openvpn start")
        end
      end
    end
  end
end
