# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Interfaces  
  
  class Aws < Base    

    def self.createVpnGateway(instance)
      response = `ec2-create-vpn-gateway --region #{instance.region} --type ipsec.1 --aws-access-key #{instance.access_key} --aws-secret-key #{instance.secret_key} --show-empty-fields`
      puts response
      r = response.split("\t");
      instance.vpn_gateway_id = r[1]      
    end
    
    def self.attachVpc(instance)
      response = `ec2-attach-vpn-gateway #{instance.gateway_id} -c #{instance.vpc} --region #{instance.region} --aws-access-key #{instance.access_key} --aws-secret-key #{instance.secret_key} --show-empty-fields`
      puts response
    end
    
    def self.createCustomerGateway(instance)
      response = `ec2-create-customer-gateway -t ipsec.1 -i #{instance.ip_address} --aws-access-key #{instance.access_key} --aws-secret-key #{instance.secret_key} --show-empty-fields`
      puts response
      r = response.split("\t");
      instance.customer_gateway_id = r[1]
    end
    
  end
  
end