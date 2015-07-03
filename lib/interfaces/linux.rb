# -*- coding: utf-8 -*-

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

  end
end
