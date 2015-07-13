# -*- coding: utf-8 -*-

require 'net/ssh'

require_relative 'base'

module Ducttape::Interfaces  
  
  class Linux < Base
  
    def self.checkOpenVpnInstalled(instance)
      Net::SSH.start(instance.ip_address, instance.username, :password => instance.password) do |ssh|
        result = ssh.exec!('rpm -qa | grep openvpn')
        if (result)
          return true
        end
      end
      return false
    end

    def self.generateCertificate(server, instance)
      Net::SSH.start(server.ip_address, server.username, :password => server.password) do |ssh|
        build = ssh.exec!("cd /etc/openvpn/easy-rsa/ && source ./vars && ./build-key #{instance.name}")
        ca = ssh.exec!("cat /etc/openvpn/easy-rsa/keys/ca.crt")
        cert = ssh.exec!("cat /etc/openvpn/easy-rsa/keys/#{instance.name}.crt")
        key = ssh.exec!("cat /etc/openvpn/easy-rsa/keys/#{instance.name}.key")
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
        return file
      end      
      return false
    end

    def self.installCertificate(instance, ovpn)
      Net::SSH.start(instance.ip_address, instance.username, :password => instance.password) do |ssh|
        ssh.exec!("touch /etc/openvpn/#{instance.name}.ovpn")
        ssh.exec!("cat > /etc/openvpn/#{instance.name}.ovpn << END
        #{ovpn}")
        return true          
      end
      return false
    end

    def self.startOpenVPN(instance)
      Net::SSH.start(instance.ip_address, instance.username, :password => instance.password) do |ssh|
        result = ssh.exec!("openvpn --config /etc/openvpn/#{instance.name}.ovpn")
        if result.include? "error"
          puts "  ERROR"
          puts result
          return false
        end
        return true
      end
      return false
    end

  end

end