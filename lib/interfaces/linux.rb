# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Interfaces  
  
  class Linux < Base

    @ip_address
    @username
    @password
    
    def getType()
      return :linux
    end
    
    def setIpAddress(ip_address)
      @ip_address = ip_address
    end
    
    def getIpAddress()
      return @ip_address
    end
    
    def setUsername(username)
      @username = username
    end
    
    def getUsername()
      return @username
    end
    
    def setPassword(password)
      @password = password
    end

  end
end
