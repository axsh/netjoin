# -*- coding: utf-8 -*-

require 'net/ssh'

require_relative 'base'

module Ducttape::Interfaces  
  
  class Linux < Base

    def self.sayHello(instance)
      Net::SSH.start( instance.ip_address, instance.username, :password => instance.password ) do|ssh|
       result = ssh.exec!('ls')
       puts result
       end
    end
        
  end
end
