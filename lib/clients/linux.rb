# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Clients  
  
  class Linux < Base

    attr_accessor :ip_address
    attr_accessor :username
    attr_accessor :password
    
    def initialize(name, server, ip_address, username, password, status = :new, error = nil)
      super(name, server, status, error)
      @ip_address = ip_address
      @username = username
      @password = password
    end
    
    def self.retrieve(name, db_client)

      server = db_client[:server]
      status = db_client[:status]
      error = db_client[:error]

      data = db_client[:data]
      ip_address = data[:ip_address]
      username = data[:username]
      password = data[:password]

      client = Linux.new(name, server, ip_address, username, password, status, error)

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
