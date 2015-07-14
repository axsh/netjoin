# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Interfaces  
  
  class Aws < Base    

    def self.createVpnGateway(client)
      response = `ec2-create-vpn-gateway --region #{client.region} --type ipsec.1 --aws-access-key #{client.access_key} --aws-secret-key #{client.secret_key} --show-empty-fields`
      puts response
      r = response.split("\t");
      client.vpn_gateway_id = r[1]      
    end
    
    def self.attachVpc(client)
      response = `ec2-attach-vpn-gateway #{client.vpn_gateway_id} -c #{client.vpc} --region #{client.region} --aws-access-key #{client.access_key} --aws-secret-key #{client.secret_key} --show-empty-fields`
      puts response
    end
    
    def self.createCustomerGateway(client, server_ip)
      response = `ec2-create-customer-gateway -t ipsec.1 -i #{server_ip} --aws-access-key #{client.access_key} --aws-secret-key #{client.secret_key} --show-empty-fields`
      puts response
      r = response.split("\t");
      client.customer_gateway_id = r[1]
    end
    
  end
  
end