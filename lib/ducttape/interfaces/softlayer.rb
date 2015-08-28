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

    def self.test(server)
      service = Softlayer.connect(server)
      begin
        templateObject = {
          'complexType' => "SoftLayer_Virtual_Guest",
          'hostname' => 'test1',
          'domain' => 'example.com',
          'startCpus' => 1,
          'maxMemory' => 1024,
          'hourlyBillingFlag' => true,
          'operatingSystemReferenceCode' => 'UBUNTU_LATEST',
          'localDiskFlag' => false
        }

        result service.createObject(templateObject);
        puts result.inspect
      rescue => e
        $stdout.print(e.inspect)
      end
    end

  end
end