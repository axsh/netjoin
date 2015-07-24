# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Models::Servers

  class Linux < Base

    attr_accessor :ip_address
    attr_accessor :mode
    attr_accessor :network
    attr_accessor :username
    attr_accessor :password
    attr_accessor :key_pem
    attr_accessor :installed
    attr_accessor :configured
    attr_accessor :file_conf
    attr_accessor :file_ca_crt
    attr_accessor :file_pem
    attr_accessor :file_crt
    attr_accessor :file_key

    def initialize(name, ip_address = nil, username = nil, mode = :dynamic, network = nil)
      super(name)
      @ip_address = ip_address
      @mode = mode
      @network = network
      @username = username
    end

    def self.retrieve(name, info)
      data = info[:data]
      entity = Linux.new(name)
      return entity
    end

    def self.fill(entity, data)
      entity.ip_address = data[:ip_address]
      entity.username = data[:username]
      entity.password = data[:password]
      entity.key_pem = data[:key_pem]
      entity.mode = data[:mode]
      entity.network = data[:network]
      entity.installed = data[:installed]
      entity.configured = data[:configured]
      entity.file_conf = data[:file_conf]
      entity.file_ca_crt = data[:file_ca_crt]
      entity.file_pem = data[:file_pem]
      entity.file_crt = data[:file_crt]
      entity.file_key = data[:file_key]
    end

    def getType()
      return :linux
    end

    def getExportData()
      data = super()
      data[:ip_address] = @ip_address
      data[:mode] = @mode
      data[:network] = @network
      data[:username] = @username
      data[:password] = @password
      data[:key_pem] = @key_pem
      data[:installed] = @installed
      data[:configured] = @configured
      data[:file_conf] = @file_conf
      data[:file_ca_crt] = @file_ca_crt
      data[:file_pem] = @file_pem
      data[:file_crt] = @file_crt
      data[:file_key] = @file_key
      return data
    end

  end

end
