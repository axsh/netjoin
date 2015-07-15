# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Servers  
  
  class Linux < Base

    attr_accessor :ip_address
    attr_accessor :dns_mode
    attr_accessor :dns_network 
    attr_accessor :username
    attr_accessor :password
    
    def initialize(name, ip_address, username, password, dns_mode = :dynamic, dns_network = nil)
      super(name)
      @ip_address = ip_address
      @dns_mode = dns_mode
      @dns_network = dns_network
      @username = username
      @password = password
    end
    
    def self.retrieve(name, info)

      data = info[:data]
      
      ip_address = data[:ip_address]
      dns_mode = data[:dns_mode]
      dns_network = data[:dns_network]
      username = data[:username]
      password = data[:password]

      client = Linux.new(name, ip_address, username, password, dns_mode, dns_network)

      return client
    end

    def getType()
      return :linux
    end

    def getExportData()
      return {
        :ip_address => @ip_address,
        :dns_mode => @dns_mode,
        :dns_network => @dns_network,
        :username => @username, 
        :password=> @password
      }
    end

  end

end
