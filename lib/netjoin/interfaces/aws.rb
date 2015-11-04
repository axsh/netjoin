# -*- coding: utf-8 -*-

require "right_aws_api"

require_relative 'linux'

module Netjoin::Interfaces

  class Aws < Linux

    def self.connect(server)
      if(!server.access_key_id or !server.secret_key)
        puts "Amazon AWS credentials missing, unable to connect!"
        return nil
      end

      if(!server.region)
        puts "Region missing, unable to connect!"
        return nil
      end
      url = "https://ec2.#{server.region}.amazonaws.com"
      return RightScale::CloudApi::AWS::EC2::Manager.new(server.access_key_id, server.secret_key, url)
    end

    def self.create_instance(server)

      if (!server.zone or !server.ami or !server.instance_type or !server.key_pair)
        puts "Unable to create instance, required parameters missing, please check the following information : zone, ami, instance_type, key_pair !"
        return nil
      end

      ec2 = connect(server)

      if (!ec2)
        "Not connected!"
      end

      response = ec2.RunInstances(
          'ImageId'            => "#{server.ami}",
          'MinCount'           => 1,
          'MaxCount'           => 1,
          'KeyName'            => "#{server.key_pair}",
          'InstanceType'       => "#{server.instance_type}",
          'SecurityGroupId'    => server.security_groups,
          'Placement'          => {
             'AvailabilityZone' => "#{server.zone}",
             'Tenancy'          => 'default' }
      )

      instance = response["RunInstancesResponse"]["instancesSet"]["item"]
      server.instance_id = instance["instanceId"]
      server.vpc_id = instance["vpcId"]
      server.private_ip_address = instance["privateIpAddress"]
    end

    def self.describe(server)
      ec2 = connect(server)

      if (!ec2)
        "Not connected!"
      end

      response = ec2.DescribeInstances(
        'InstanceId'      => "#{server.instance_id}"
      )

      return response
    end

    def self.status(server)

      ec2 = connect(server)

      if (!ec2)
        "Not connected!"
      end

      response = ec2.DescribeInstanceStatus(
        'InstanceId'      => "#{server.instance_id}"
      )

      if !(response["DescribeInstanceStatusResponse"]["instanceStatusSet"])
        return nil
      end
      return response["DescribeInstanceStatusResponse"]["instanceStatusSet"]["item"]
    end


    def self.public_ip_address(server)
      if (!server.instance_id)
        puts "Instance ID is missing!"
        return
      end

      ec2 = connect(server)

      if (!ec2)
        "Not connected!"
      end

      response = ec2.DescribeInstances(
        'InstanceId'      => "#{server.instance_id}"
      )

      instance = response["DescribeInstancesResponse"]["reservationSet"]["item"]["instancesSet"]["item"]
      server.ip_address = instance["ipAddress"]
      server.public_dns_name = instance["dnsName"]
      if(!server.ip_address or !server.public_dns_name)
        return false
      end
      return true
    end

  end
end
