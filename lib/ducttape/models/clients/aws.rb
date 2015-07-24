# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Models::Clients

  class Aws < Base

    attr_accessor :region
    attr_accessor :vpc
    attr_accessor :ip_address
    attr_accessor :access_key
    attr_accessor :secret_key

    attr_accessor :vpn_gateway_id
    attr_accessor :customer_gateway_id

    def initialize(name, server, region, vpc, access_key, secret_key)
      super(name, server)
      @region = region
      @vpc = vpc
      @access_key = access_key
      @secret_key = secret_key
    end

    def getType()
      return :aws
    end

    def getExportData()
      return {
        :region => @region,
        :vpc => @vpc,
        :access_key => @access_key,
        :secret_key => @secret_key,
        :vpn_gateway_id => @vpn_gateway_id,
        :customer_gateway_id => @customer_gateway_id
      }

    end

  end

end
