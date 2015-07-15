# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Servers  
  
  class Linux < Base

    attr_accessor :ip_address
    attr_accessor :username
    attr_accessor :password
    
    def initialize(name, ip_address, username, password)
      super(name)
      @ip_address = ip_address
      @username = username
      @password = password
    end
    
    def self.retrieve(name, info)

      data = info[:data]
      
      ip_address = data[:ip_address]
      username = data[:username]
      password = data[:password]

      client = Linux.new(name, ip_address, username, password)

      return client
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
