# -*- coding: utf-8 -*-

require_relative 'linux'

module Ducttape::Models::Servers

  class Softlayer < Linux

    attr_accessor :domain
    attr_accessor :hostname
    attr_accessor :ssl_api_key
    attr_accessor :ssl_api_username

    def initialize(name, ssl_api_key, ssl_api_username)
      super(name)
      @ssl_api_key = ssl_api_key
      @ssl_api_username = ssl_api_username
    end

    def self.retrieve(name, info)
      data = info[:data]
      entity = Aws.new(name)
      self.fill(entity, data)
      entity.domain = data[:domain]
      entity.hostname = data[:hostname]
      entity.ssl_api_key = data[:ssl_api_key]
      entity.ssl_api_username = data[:ssl_api_username]
      return entity
    end

    def type()
      return :aws
    end

    def export_data()
      data = super()
      data[:ssl_api_key] = @ssl_api_key
      data[:ssl_api_username] = @ssl_api_username
      return data
    end

  end

end