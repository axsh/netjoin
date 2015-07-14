# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Clients  
  
  class Linux < Base

    attr_accessor :ip_address
    attr_accessor :username
    attr_accessor :password
    
    def initialize(name, server, ip_address, username, password)
      super(name, server)
      @ip_address = ip_address
      @username = username
      @password = password
    end

    def getType()
      return :linux
    end

    def getExportData()
      return {
        :ip_address => @ip_address, 
        :username => @username, 
        :password=> @password
      }
    end

  end

end
