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
    
    def self.describe(server)
      ec2 = connectAws(server)
      
      if (!ec2)
        "Not connected!"
      end

      response = ec2.DescribeInstances(
        'InstanceId'      => "#{server.instance_id}"    
      )

      puts response.to_yaml()
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

      puts response.to_yaml()
            
      server.ip_address = response["DescribeInstancesResponse"]["reservationSet"]["item"]["instancesSet"]["item"]["ipAddress"]
      server.public_dns_name = response["DescribeInstancesResponse"]["reservationSet"]["item"]["instancesSet"]["item"]["dnsName"]
      if(!server.ip_address or !server.public_dns_name)
        return false
      end
      return true
    end
    
    def self.getAuth(client)
      if (client.key_pem)
        return { :keys => "" }
      end
      return { :password => client.password }
    end
    
    def self.testing(client)
      puts "testing"
      Net::SSH.start(client.public_dns_name, client.username, Aws.getAuth(client)) do |ssh|
        response = ssh.exec!("ifconfig")
        puts response
      end
    end
    
    def self.uploadFile(client, source, destination)
      Net::SCP.start(client.ip_address, client.username, Aws.getAuth(client)) do |scp|
        scp.upload!(source, destination)
        return true
      end
      return false
    end
  
    def self.checkOpenVpnInstalled(client)
      Net::SSH.start(client.ip_address, client.username, Aws.getAuth(client)) do |ssh|
        result = ssh.exec!('rpm -qa | grep openvpn')
        if (result)
          return true
        end
      end
      return false
    end
    
    def self.installOpenVpn(client)
      Net::SSH.start(client.ip_address, client.username, Aws.getAuth(client)) do |ssh|
        result = ssh.exec!('yum install -y openvpn')
        if (result.end_with?("Complete!\n"))
          return true
        end
      end
      return false
    end
    
    def self.installCertificate(client)
      return Linux.uploadFile(client, "keys/#{client.name}.ovpn", "/etc/openvpn/#{client.name}.ovpn")
    end

    def self.startOpenVpnServer(client)
      Net::SSH.start(client.ip_address, client.username, Aws.getAuth(client)) do |ssh|
        ssh.exec!("service openvpn restart")
        return true
      end
      return false
    end
  end
  
end