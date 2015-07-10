# -*- coding: utf-8 -*-

require 'net/ssh'

require_relative 'base'

module Ducttape::Interfaces  
  
  class Linux < Base
  
    def self.checkOpenVpnInstalled(instance)
      begin
        Net::SSH.start(instance.ip_address, instance.username, :password => instance.password) do |ssh|
          result = ssh.exec!('rpm -qa | grep openvpn')
          if (result)
            return true
          end         
        end       
      end
      return false
    end
    
    def self.generateCertificate(server, instance)
      begin
        Net::SSH.start(instance.ip_address, instance.username, :password => instance.password) do |ssh|
          ssh.exec!('cd /etc/openvpn/easy-rsa')
          ssh.exec!('./build-key #{instance.name}')
          ca = ssh.exec!('cat keys/ca.crt')
          cert = ssh.exec!('cat keys/#{instance.name}.crt')
          key = ssh.exec!('cat keys/#{instance.name}.key')
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
          </key>"
          return file
        end      
      end
      return nil
    end
        
    def self.installCertificate(instance, ovpn)
      begin
        Net::SSH.start(instance.ip_address, instance.username, :password => instance.password) do |ssh|
          ssh.exec!("echo #{ovpn} > /etc/openvpn/#{instance.name}.ovpn")
        end
      rescue
        return false
      end
      return true
    end
    
    def self.startOpenVPN(instance)
      begin
        Net::SSH.start(instance.ip_address, instance.username, :password => instance.password) do |ssh|
          ssh.exec!("openvpn --config /etc/openvpn/#{instance.name}.ovpn")
        end
      rescue
        return false
      end
      return true
    end
        
  end
  
end