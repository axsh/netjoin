# -*- coding: utf-8 -*-

module Netjoin::Drivers
  module Openvpn
    def self.install(node, network)
      tmp_config_file = "./tmp_config.conf"

      f = File.open(tmp_config_file, "w")
      f.write("persist-remote-ip")
      f.write("dev tun")
      f.write("persist-tun")
      f.write("persist-local-ip")
      f.write("comp-lzo")
      f.write("user nobody")
      f.write("group nobody")
      f.write("log vpn.log")
      f.write("verb 3")
      f.write("secret #{network.psk}")
      f.close

      if node.ssh_from
        ip = node.ssh_from['ssh_ip_address']
        user = node.ssh_from['ssh_user']
        password = node.ssh_from['ssh_password']

        Net::SCP.upload!(ip, user, tmp_config_file, "/tmp", :ssh => {:password => password})
        Net::SSH.start(ip, user, :password => password) do |ssh|
          _i = node.ssh_ip_address
          _u = node.ssh_user
          _p = node.ssh_password

          ssh.exec!("ssh #{_u}@#{_i} yum -y install epel-release")
          ssh.exec!("ssh #{_u}@#{_i} yum -y install openvpn")
          ssh.exec!("ssh #{_u}@#{_i} scp /tmp/tmp_config.conf #{_u}@#{_i}:/etc/openvpn")
        end
      end
    end
  end
end
