# -*- coding: utf-8 -*-

require "softlayer_api"

require_relative 'linux'

module Netjoin::Interfaces

  class Softlayer < Linux

    def self.client(server)
      return SoftLayer::Client.new(
          :username => server.ssl_api_username,
          :api_key => server.ssl_api_key,
          :timeout => 120
        )
    end

    def self.service(server, name)
      return client(server).service_named(name)
    end

    def self.getServer(server)
      begin
        client = client(server)
        server = SoftLayer::VirtualServer.server_with_id(server.instance_id, { :client => client } )
        return server
      rescue => e
        puts e.inspect
      end
      return nil
    end

    def self.list_datacenters(server)
      client = Softlayer.service(server, "SoftLayer_Location_Datacenter")
      begin

        result = client.getDatacenters()
        puts result.inspect
      rescue => e
        puts e.inspect
        return false
      end
      return true
    end

    def self.create(server)
      client = Softlayer.service(server, "SoftLayer_Virtual_Guest")
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
        server.instance_id = result["id"]

      rescue => e
        puts e.inspect
        return false
      end
      return true
    end

  end
end