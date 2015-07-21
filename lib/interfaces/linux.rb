# -*- coding: utf-8 -*-

require 'csv'
require 'net/scp'
require 'net/ssh'

require_relative 'base'

module Ducttape::Interfaces
  
  class Linux < Base
    
    def self.uploadFile(client, source, destination)
      Net::SCP.start(client.ip_address, client.username, :password => client.password) do |scp|
        scp.upload!(source, destination)
        return true
      end
      return false
    end
  
    def self.checkOpenVpnInstalled(client)
      Net::SSH.start(client.ip_address, client.username, :password => client.password) do |ssh|
        result = ssh.exec!('rpm -qa | grep openvpn')
        if (result)
          return true
        end
      end
      return false
    end
    
    def self.installOpenVpn(client)
      Net::SSH.start(client.ip_address, client.username, :password => client.password) do |ssh|
        result = ssh.exec!('yum install -y openvpn')
        if (result.end_with?("Complete!\n"))
          return true
        end
      end
      return false
    end

    def self.generateCertificate(server, client)
      Net::SSH.start(server.ip_address, server.username, :password => server.password) do |ssh|
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
END"
        if (!ca or !cert or !key)
          puts "  ERROR"
          puts build
          return false
        end
        DucttapeCLI::CLI.writeFile("keys/#{client.name}.ovpn",file)
        return file
      end      
      return false
    end

    def self.installCertificate(client)
      return Linux.uploadFile(client, "keys/#{client.name}.ovpn", "/etc/openvpn/#{client.name}.ovpn")
    end

    def self.startOpenVpnServer(client)
      Net::SSH.start(client.ip_address, client.username, :password => client.password) do |ssh|
        ssh.exec!("service openvpn restart")
        return true
      end
      return false
    end
    
    def self.startOpenVpnClient(client)
      Net::SSH.start(client.ip_address, client.username, :password => client.password) do |ssh|
        ssh.exec!("openvpn --config /etc/openvpn/#{client.name}.ovpn --daemon")
        return true
      end
      return false
    end
    
    def self.setVpnIpAddress(server, client)
      if (!Ducttape::Interfaces::Linux.getVpnIpAddress(server, client))
        Net::SSH.start(server.ip_address, server.username, :password => server.password) do |ssh|
          ssh.exec!("echo #{client.name},#{client.vpn_ip_address} >> /etc/openvpn/ipp.txt")
        end
      end      
    end
    
    def self.getVpnIpAddress(server, client)
      Net::SSH.start(server.ip_address, server.username, :password => server.password) do |ssh|
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