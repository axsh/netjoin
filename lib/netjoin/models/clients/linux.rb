# -*- coding: utf-8 -*-

require_relative 'base'

module Netjoin::Models::Clients

  class Linux < Base

    attr_accessor :ip_address
    attr_accessor :username
    attr_accessor :password
    attr_accessor :key_pem
    attr_accessor :vpn_ip_address
    attr_accessor :generate_key
    attr_accessor :file_key

    def initialize(name, server, ip_address, username, password = nil, key_pem = nil)
      super(name, server)
      @ip_address = ip_address
      @username = username
      @password = password
      @key_pem = key_pem
    end

    def self.retrieve(name, info)
      server = info[:server]
      data = info[:data]
      client = Linux.new(name, server, data[:ip_address], data[:username])
      client.error = info[:error]
      if(data[:generate_key])
        if(data[:generate_key] == true)
          client.generate_key = true
        else
          client.generate_key = false
        end
      end
      client.key_pem = data[:key_pem]
      client.password= data[:password]
      client.status = info[:status]
      client.vpn_ip_address = data[:vpn_ip_address]
      client.file_key = data[:file_key]
      return client
    end

    def type()
      return :linux
    end

    def export_data()
      return {
        :generate_key => @generate_key,
        :file_key => @file_key,
        :ip_address => @ip_address,
        :key_pem => @key_pem,
        :password => @password,
        :username => @username,
        :vpn_ip_address => @vpn_ip_address,
      }
    end

  end

end
