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

    def self.create(server)
      service = Softlayer.connect(server)
      begin
        templateObject = {
          'complexType' => "SoftLayer_Virtual_Guest",
          'hostname' => server.hostname,
          'domain' => server.domain,
          'startCpus' => 1,
          'maxMemory' => 1024,
          'hourlyBillingFlag' => true,
          'operatingSystemReferenceCode' => 'CENTOS_6_64',
          'localDiskFlag' => false
        }

        result service.createObject(templateObject);
        puts result.inspect
      rescue => e
        $stdout.print(e.inspect)
        return false
      end
      return true
    end

  end
end