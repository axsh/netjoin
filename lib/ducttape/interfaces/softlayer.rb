# -*- coding: utf-8 -*-

require "softlayer_api"

require_relative 'linux'

module Ducttape::Interfaces

  class Softlayer < Linux

    def self.connect(server, name)
      return SoftLayer::Service.new(name,
          :username => server.ssl_api_username,
          :api_key => server.ssl_api_key
        )
    end

    def self.test(server)
      client = Softlayer.connect(server, "SoftLayer_Location_Datacenter")
      begin

        result = client.getDatacenters();
        puts result.inspect
      rescue => e
        $stdout.print(e.inspect)
        return false
      end
      return true
    end

    def self.create(server)
      client = Softlayer.connect(server, "SoftLayer_Virtual_Guest")
      begin
        templateObject = {
          'complexType' => "SoftLayer_Virtual_Guest",
          'hostname' => server.hostname,
          'domain' => server.domain,
          'startCpus' => 1,
          'maxMemory' => 1024,
          'hourlyBillingFlag' => 'true',
          'operatingSystemReferenceCode' => 'CENTOS_6_64',
          'localDiskFlag' => 'false',
          'datacenter' => { 'name' => 'tok02' }
        }

        result = client.createObject(templateObject);
        puts result.inspect
      rescue => e
        $stdout.print(e.inspect)
        return false
      end
      return true
    end

  end
end