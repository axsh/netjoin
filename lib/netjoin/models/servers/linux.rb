# -*- coding: utf-8 -*-

require_relative 'base'

module Netjoin::Models::Servers

  class Linux < Base

    attr_accessor :mode
    attr_accessor :master
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
    attr_accessor :network_ip
    attr_accessor :network_prefix
    attr_accessor :password
    attr_accessor :port
    attr_accessor :username

    def initialize(name, ip_address = nil, username = nil, mode = "dynamic")
      super(name)
      @ip_address = ip_address
      @mode = mode
      @username = username
    end

    def self.retrieve(name, info)
      data = info[:data]
      entity = Linux.new(name)
      fill(entity, data)
      return entity
    end

    def self.fill(entity, data)
      entity.mode = data[:mode]
      entity.master = data[:master]
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
      entity.network_ip = data[:network_ip]
      entity.network_prefix = data[:network_prefix]
      entity.password = data[:password]
      entity.port = data[:port]
      entity.username = data[:username]
    end

    def type()
      return :linux
    end

    def export_data()
      data = super()
      data[:mode] = @mode
      data[:master] = @master
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
      data[:network_ip] = @network_ip
      data[:network_prefix] = @network_prefix
      data[:password] = @password
      data[:port] = @port
      data[:username] = @username
      return data
    end

  end

end
