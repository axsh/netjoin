# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Interfaces  
  
  class Aws < Base    

    def self.createVpnGateway(instance)
      response = `ec2-create-vpn-gateway --region #{instance.region} --type ipsec.1 --aws-access-key #{instance.access_key} --aws-secret-key #{instance.secret_key}`
      puts response
    end
  end
  
end