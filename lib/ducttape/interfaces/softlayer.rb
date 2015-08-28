# -*- coding: utf-8 -*-

require "softlayer_api"

require_relative 'linux'

module Ducttape::Interfaces

  class Softlayer < Linux

    def self.connect(server)
      return SoftLayer::Service.new("SoftLayer_Account",
          :username => server.ssl_api_username,
          :api_key => server.ssl_api_key
        )
    end

  end
end