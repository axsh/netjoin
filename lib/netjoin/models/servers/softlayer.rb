# -*- coding: utf-8 -*-

require_relative 'linux'

module Netjoin::Models::Servers

  class Softlayer < Linux

    attr_accessor :domain
    attr_accessor :hostname
    attr_accessor :instance_id
    attr_accessor :ssl_api_key
    attr_accessor :ssl_api_username

    def initialize(name, ssl_api_key, ssl_api_username)
      super(name)
      @ssl_api_key = ssl_api_key
      @ssl_api_username = ssl_api_username
    end

    def self.retrieve(name, info)
      data = info[:data]
      entity = Softlayer.new(name, data[:ssl_api_key], data[:ssl_api_username])
      self.fill(entity, data)
      entity.domain = data[:domain]
      entity.hostname = data[:hostname]
      entity.instance_id = data[:instance_id]
      return entity
    end

    def type()
      return :softlayer
    end

    def export_data()
      data = super()
      data[:domain] = @domain
      data[:hostname] = @hostname
      data[:instance_id] = @instance_id
      data[:ssl_api_key] = @ssl_api_key
      data[:ssl_api_username] = @ssl_api_username
      return data
    end

  end

end