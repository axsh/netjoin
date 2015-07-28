# -*- coding: utf-8 -*-

require 'csv'
require 'net/scp'
require 'net/ssh'

require_relative 'base'

module Ducttape::Interfaces

  class Linux < Base

    def self.upload_file(client, source, destination)
      Net::SCP.start(client.ip_address, client.username, Base.auth_param(client)) do |scp|
        scp.upload!(source, destination)
        return true
      end
      return false
    end

    def self.check_openvpn_installed(client)
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        result = ssh.exec!('rpm -qa | grep openvpn')
        if (result)
          return true
        end
      end
      return false
    end

    def self.install_openvpn(client)
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        result = ssh.exec!('yum install -y openvpn')
        if (result.end_with?("Complete!\n"))
          return true
        end
      end
      return false
    end

    def self.generate_certificate(server, client)
      Net::SSH.start(server.ip_address, server.username, Base.auth_param(client)) do |ssh|
        ls = ssh.exec!("ls /etc/openvpn/easy-rsa/keys/#{client.name}.crt")
        if(ls == "/etc/openvpn/easy-rsa/keys/#{client.name}.crt\n")
          puts "    Already generated"
        else
          build = ssh.exec!("cd /etc/openvpn/easy-rsa/ && source ./vars && ./build-key #{client.name}")
        end
        ca = ssh.exec!("cat /etc/openvpn/easy-rsa/keys/ca.crt")
        cert = ssh.exec!("cat /etc/openvpn/easy-rsa/keys/#{client.name}.crt")
        key = ssh.exec!("cat /etc/openvpn/easy-rsa/keys/#{client.name}.key")
        file = "client
dev tun
proto udp
remote #{server.ip_address} 1194
resolv-retry infinite
nobind
persist-key
persist-tun
comp-lzo
verb 3
<ca>
#{ca}
</ca>
<cert>
#{cert}
</cert>
<key>
#{key}
</key>
"
        if (!ca or !cert or !key)
          puts "  ERROR"
          puts build
          return false
        end
        Ducttape::Cli::Root.write_file("keys/#{client.name}.ovpn",file)
        return file
      end
      return false
    end

    def self.install_certificate(client)
      return Linux.upload_file(client, "keys/#{client.name}.ovpn", "/etc/openvpn/#{client.name}.ovpn")
    end

    def self.start_openvpn_server(client)
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        ssh.exec!("service openvpn restart")
        return true
      end
      return false
    end

    def self.start_openvpn_client(client)
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        ssh.exec!("service openvpn restart")
        ssh.exec!("openvpn --config /etc/openvpn/#{client.name}.ovpn --daemon")
        return true
      end
      return false
    end

    def self.set_vpn_ip_address(server, client)
      if (!Ducttape::Interfaces::Linux.get_vpn_ip_address(server, client))
        Net::SSH.start(server.ip_address, server.username, Base.auth_param(client)) do |ssh|
          ssh.exec!("echo #{client.name},#{client.vpn_ip_address} >> /etc/openvpn/ipp.txt")
        end
      end
    end

    def self.get_vpn_ip_address(server, client)
      Net::SSH.start(server.ip_address, server.username, Base.auth_param(client)) do |ssh|
        ipp = ssh.exec!("cat /etc/openvpn/ipp.txt")
        if (ipp)
          csv = CSV.new(ipp)
          csv.each { |row|
            name, ip_address = row
            if (name == client.name())
              return ip_address
            end
          }
        end
      end
      return nil
    end

  end

end