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
        return nil
      end

      return RightScale::CloudApi::AWS::EC2::Manager.new(server.access_key_id, server.secret_key, "https://ec2.#{server.region}.amazonaws.com")
    end
    
    def self.createInstance(server)
      
      if (!server.zone or !server.ami or !server.instance_type or !server.key_pair)
        puts "Unable to create instance, required parameters missing, please check the following information : zone, ami, instance_type, key_pair !"
        return nil
      end
      
      ec2 = connectAws(server)
      
      if (!ec2)
        "Not connected!"
      end
            
      response = ec2.RunInstances(
          'ImageId'            => "#{server.ami}",
          'MinCount'           => 1,
          'MaxCount'           => 1,
          'KeyName'            => "#{server.key_pair}",
          'InstanceType'       => "#{server.instance_type}",
          'Placement'          => {
             'AvailabilityZone' => "#{server.zone}",
             'Tenancy'          => 'default' }
      )

      puts response.to_yaml()
      
      server.instance_id = response["RunInstancesResponse"]["instancesSet"]["item"]["instanceId"]
      server.vpc_id = response["RunInstancesResponse"]["instancesSet"]["item"]["vpcId"]
      server.private_ip_address = response["RunInstancesResponse"]["instancesSet"]["item"]["privateIpAddress"]
        
    end
    
    def self.getStatus(server)

      ec2 = connectAws(server)

      if (!ec2)
        "Not connected!"
      end

      response = ec2.DescribeInstanceStatus(
        'InstanceId'      => "#{server.instance_id}"    
      )

      puts response.to_yaml()

      if !(response["DescribeInstanceStatusResponse"]["instanceStatusSet"])
        return nil
      end      
      state = response["DescribeInstanceStatusResponse"]["instanceStatusSet"]["item"]["instanceState"]
      return state
    end
    
    
    def self.getPublicIpAddress(server)
      if (!server.instance_id)
        puts "Instance ID is missing!"
        return
      end

      ec2 = connectAws(server)
      
      if (!ec2)
        "Not connected!"
      end

      response = ec2.DescribeInstances(
        'InstanceId'      => "#{server.instance_id}"    
      )
      
      ip_address = response["DescribeInstancesResponse"]["reservationSet"]["item"]["instancesSet"]["item"]["ipAddress"]
        
      return ip_address
    end
    
  end
  
end