# -*- coding: utf-8 -*-

require 'net/ssh'

require_relative 'base'

module Ducttape::Interfaces  
  
  class Linux < Base
  
    def self.checkOpenVpnInstalled(instance)
      Net::SSH.start( instance.ip_address, instance.username, :password => instance.password ) do|ssh|
         result = ssh.exec!('rpm -qa | grep openvpn')
         if(result)
           return true
         end         
       end
       return false;
    end
        
  end
end
