# -*- coding: utf-8 -*-

require_relative 'linux'

module Ducttape::Servers  

  class Aws < Linux

    attr_accessor :region
    attr_accessor :zone
    attr_accessor :access_key_id
    attr_accessor :secret_key
    attr_accessor :ami
    attr_accessor :instance_type
    attr_accessor :key_pair
    attr_accessor :instance_id
    attr_accessor :vpc_id
    attr_accessor :private_ip_address

    def initialize(name, region = nil, zone = nil, access_key_id = nil, secret_key = nil, ami = nil, instance_type = nil, key_pair = nil)
      super(name)
      @region = region
      @zone = zone
      @access_key_id = access_key_id
      @secret_key = secret_key
      @ami = ami
      @instance_type = instance_type
      @key_pair = key_pair
    end
    
    def self.retrieve(name, info)
      data = info[:data]
      entity = Aws.new(name)
      self.fill(entity, data)
      entity.region = data[:region]
      entity.zone = data[:zone]
      entity.access_key_id = data[:access_key_id]
      entity.secret_key = data[:secret_key]
      entity.ami  = data[:ami]
      entity.instance_type  = data[:instance_type]
      entity.key_pair  = data[:key_pair]
      entity.instance_id = data[:instance_id]
      entity.vpc_id = data[:vpc_id]
      entity.private_ip_address = data[:private_ip_address]
      return entity
    end

    def getType()
      return :aws
    end

    def getExportData()
      data = super()
      data[:region] = @region
      data[:zone] = @zone
      data[:access_key_id] = @access_key_id
      data[:secret_key] = @secret_key
      data[:ami] = @ami
      data[:instance_type] = @instance_type
      data[:key_pair] = @key_pair
      data[:instance_id] = @instance_id
      data[:vpc_id] = @vpc_id
      data[:private_ip_address] = @private_ip_address
      return data
    end

  end

end