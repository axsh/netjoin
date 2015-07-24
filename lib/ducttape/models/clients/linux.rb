# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Models::Clients  
  
  class Linux < Base

    attr_accessor :ip_address
    attr_accessor :username
    attr_accessor :password
    attr_accessor :vpn_ip_address
    attr_accessor :generate_key
    
    def initialize(name, server, ip_address, username, password)
      super(name, server)
      @ip_address = ip_address
      @username = username
      @password = password
    end
    
    def self.retrieve(name, info)

      server = info[:server]
      status = info[:status]
      error = info[:error]

      data = info[:data]
      ip_address = data[:ip_address]
      username = data[:username]
      password = data[:password]
      vpn_ip_address = data[:vpn_ip_address]
      generate_key = data[:generate_key]
        
      client = Linux.new(name, server, ip_address, username, password)
      client.status = status
      client.error = error
      client.vpn_ip_address = vpn_ip_address
      client.generate_key = generate_key

      return client
    end

    def getType()
      return :linux
    end

    def getExportData()
      return {
        :ip_address => @ip_address, 
        :username => @username, 
        :password=> @password,
        :vpn_ip_address => @vpn_ip_address,
        :generate_key => @generate_key
      }
    end

  end

end
