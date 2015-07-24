# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Models::Clients

  class Linux < Base

    attr_accessor :ip_address
    attr_accessor :username
    attr_accessor :password
    attr_accessor :key_pem
    attr_accessor :vpn_ip_address
    attr_accessor :generate_key

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
      client.password= data[:password]
      client.key_pem = info[:key_pem]
      client.status = info[:status]
      client.error = info[:error]
      client.vpn_ip_address = data[:vpn_ip_address]
      client.generate_key = data[:generate_key]

      return client
    end

    def type()
      return :linux
    end

    def export_data()
      return {
        :ip_address => @ip_address,
        :username => @username,
        :password => @password,
        :key_pem => @key_pem,
        :vpn_ip_address => @vpn_ip_address,
        :generate_key => @generate_key
      }
    end

  end

end
