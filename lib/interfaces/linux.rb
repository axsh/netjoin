# -*- coding: utf-8 -*-

require 'net/ssh'
require 'net/scp'

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
    
    def self.installCertificate(instance, cert_parth)
      Net::SCP.start(instance.ip_address, instance.username, :password => instance.password) do |scp|
        scp.upload(cert_parth, "/etc/openvpn/")
      end
      return true
    end
        
  end
  
end