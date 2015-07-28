# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Models::Servers

  class Linux < Base

    attr_accessor :configured
    attr_accessor :file_ca_crt
    attr_accessor :file_conf
    attr_accessor :file_crt
    attr_accessor :file_key
    attr_accessor :file_pem
    attr_accessor :installed
    attr_accessor :ip_address
    attr_accessor :key_pem
    attr_accessor :mode
    attr_accessor :network
    attr_accessor :password
    attr_accessor :username

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
      fill(entity, data)
      return entity
    end

    def self.fill(entity, data)
      entity.configured = data[:configured]
      entity.file_ca_crt = data[:file_ca_crt]
      entity.file_conf = data[:file_conf]
      entity.file_crt = data[:file_crt]
      entity.file_key = data[:file_key]
      entity.file_pem = data[:file_pem]
      entity.installed = data[:installed]
      entity.key_pem = data[:key_pem]
      entity.ip_address = data[:ip_address]
      entity.mode = data[:mode]
      entity.network = data[:network]
      entity.password = data[:password]
      entity.username = data[:username]
    end

    def type()
      return :linux
    end

    def export_data()
      data = super()
      data[:configured] = @configured
      data[:file_ca_crt] = @file_ca_crt
      data[:file_conf] = @file_conf
      data[:file_crt] = @file_crt
      data[:file_key] = @file_key
      data[:file_pem] = @file_pem
      data[:installed] = @installed
      data[:ip_address] = @ip_address
      data[:key_pem] = @key_pem
      data[:mode] = @mode
      data[:network] = @network
      data[:password] = @password
      data[:username] = @username
      return data
    end

  end

end
