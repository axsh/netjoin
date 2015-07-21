# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Servers  
  
  class Linux < Base

    attr_accessor :ip_address
    attr_accessor :mode
    attr_accessor :network 
    attr_accessor :username
    attr_accessor :password
    attr_accessor :installed
    attr_accessor :configured
    attr_accessor :file_conf
    attr_accessor :file_ca_crt
    attr_accessor :file_pem
    attr_accessor :file_crt
    attr_accessor :file_key
    
    def initialize(name, ip_address, username, password, mode = :dynamic, network = nil)
      super(name)
      @ip_address = ip_address
      @mode = mode
      @network = network
      @username = username
      @password = password
    end
    
    def self.retrieve(name, info)

      data = info[:data]
      
      ip_address = data[:ip_address]
      mode = data[:mode]
      network = data[:network]
      username = data[:username]
      password = data[:password]
      installed = data[:installed]
      configured = data[:configured]
      file_conf = data[:file_conf]
      file_ca_crt = data[:file_ca_crt]
      file_pem = data[:file_pem]
      file_crt = data[:file_crt]
      file_key = data[:file_key]

      client = Linux.new(name, ip_address, username, password, mode, network)
      client.installed = installed
      client.configured = configured
      client.file_conf = file_conf
      client.file_ca_crt = file_ca_crt
      client.file_pem = file_pem
      client.file_crt = file_crt
      client.file_key = file_key

      return client
    end

    def getType()
      return :linux
    end

    def getExportData()
      return {
        :ip_address => @ip_address,
        :mode => @mode,
        :network => @network,
        :username => @username, 
        :password=> @password,
        :installed => @installed,
        :configured => @configured,
        :file_conf => @file_conf,
        :file_ca_crt => @file_ca_crt,
        :file_pem => @file_pem,
        :file_crt => @file_crt,
        :file_key => @file_key,
      }
    end

  end

end
