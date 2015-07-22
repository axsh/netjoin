# -*- coding: utf-8 -*-

require "right_aws_api"

require_relative 'base'

module Ducttape::Interfaces  
  
  class Aws < Base    

    def self.connectAws(server)
      if(!server.access_key_id or !server.secret_key)
        puts "Amazon AWS credentials missing, unable to connect!"
        return nil
      end
      
      if(!server.region)
        puts "Region missing, unable to connect!"
      end

      return RightScale::CloudApi::AWS::EC2::Manager.new(server.access_key_id, server.secret_key, "https://ec2.#{server.region}.amazonaws.com")
    end
    
    def self.createInstance(server)
      
      if (!server.zone or !server.ami or !server.instance_type)
        puts "Unable to create instance, required parameters missing, please check the following information : zone, ami, instance_type!"
        return nil
      end
      
      ec2 = connectAws(server)
            
      response = ec2.RunInstances(
          'ImageId'            => "#{server.ami}",
          'MinCount'           => 1,
          'MaxCount'           => 1,
          'InstanceType'       => "#{server.instance_type}",
          'Placement'         => {
             'AvailabilityZone' => "#{server.zone}",
             'Tenancy'          => 'default' }
      )
      puts response.to_yaml()
      
      server.instance_id = response["RunInstancesResponse"]["instancesSet"]["item"]["instanceId"]
      server.vpc_id = response["RunInstancesResponse"]["instancesSet"]["item"]["vpcId"]
      server.private_ip_address = response["RunInstancesResponse"]["instancesSet"]["item"]["privateIpAddress"]
        
    end
    
    def self.getPublicIpAddress(server)
      if (!server.instance_id)
        puts "Instance ID is missing!"
        return
      end

      ec2 = connectAws(server)

      response = ec2.DescribeInstances(
        'InstanceId'      => "#{server.instance_id}"    
      )
      
      ip_address = response["DescribeInstancesResponse"]["reservationSet"]["item"]["instancesSet"]["item"]["networkInterfaceSet"]["item"]["association"]["publicIp"]
        
      return ip_address
    end
    
  end
  
end