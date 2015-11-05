# -*- coding: utf-8 -*-

require 'aws-sdk'

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
      Aws.config.update({
        region: server.region,
        credentials: Aws::Credentials.new(server.access_key_id, server.secret_key)
      })
    end

    def self.create_instance(server)

      required_params = [
        :zone,
        :ami,
        :instance_type,
        :key_pair,
        :vpc_cidr,
        :subnet_cidr,
        :global_cidr
      ]

      required_params.each do |param|
        next if server.__send__(param)
        puts "Missing param #{param}"
        return
      end

      ec2 = Aws::EC2::Client.new

      if vpc_id == ""
        vpc_id = ec2.create_vpc(
          cidr_block: vpc_cidr,
          instance_tenancy: "default",
        ).vpc.vpc_id
        puts "Create VPC #{vpc_id}"
      end
      vpc = Aws::EC2::Vpc.new(id: vpc_id)

      if subnet_id == ""
        subnet_id = ec2.create_subnet(
          vpc_id: vpc_id,
          cidr_block: subnet_cidr,
        ).subnet.subnet_id
        puts "Create subnet #{subnet_id}"
      end
      subnet = Aws::EC2::Subnet.new(id: subnet_id)

      if route_table_id == ""
        route_table_id = ec2.describe_route_tables(
          filters: [
            { name: "vpc-id", values: [vpc_id] }
          ]
        ).route_tables.first.route_table_id
        puts "Create route table #{route_table_id}"
      end

      ec2.associate_route_table({
        subnet_id: subnet_id,
        route_table_id: route_table_id
      })

      if igw_id == ""
        igw_id = ec2.create_internet_gateway.internet_gateway.internet_gateway_id
      end
      igw = Aws::EC2::InternetGateway.new(id: igw_id)
      puts "Create igw #{igw_id}"

      if igw.attachments.empty?
        ec2.attach_internet_gateway({
          internet_gateway_id: igw_id,
          vpc_id: vpc_id
        })
      end

      ec2.create_route({
        route_table_id: route_table_id,
        destination_cidr_block: '0.0.0.0/0',
        gateway_id: igw_id
      })

      if secg_id == ""
        secg_id = ec2.create_security_group({
          group_name: "netjoin-default",
          description: "netjoin-default",
          vpc_id: vpc_id
        }).group_id
      end
      secg = Aws::EC2::SecurityGroup.new(id: secg_id)
      puts "Create secg #{secg_id}"

      if secg.data.ip_permissions.empty?
        secg.authorize_ingress(ip_permissions: [{ip_protocol: "tcp", from_port: 1194, to_port: 1194, ip_ranges: [{cidr_ip: "#{global_cidr}"}]}])
        secg.authorize_ingress(ip_permissions: [{ip_protocol: "tcp", from_port: 22, to_port: 22, ip_ranges: [{cidr_ip: "#{global_cidr}"}]}])
        secg.authorize_ingress(ip_permissions: [{ip_protocol: "-1", from_port: nil, to_port: nil, user_id_group_pairs: [{group_id: "#{secg.id}"}]}])

        secg.authorize_egress(ip_permissions: [{ip_protocol: "tcp", from_port: 1194, to_port: 1194, ip_ranges: [{cidr_ip: "#{global_cidr}"}]}])
      end
      secg.load
      puts "Create rules #{secg.data}"

      instance_id = ec2.run_instances({
        image_id: image_id,
        min_count: 1,
        max_count: 1,
        key_name: 'axsh-tis',
        instance_type: 't2.micro',
        network_interfaces: [
          { device_index: 0, associate_public_ip_address: true, subnet_id: subnet_id, groups: [secg_id] }
        ]
      }).instances.first.instance_id
      i = Aws::EC2::Instance.new(id: instance_id)
      puts "Create instance #{instance_id}"
      i.wait_until_running

      server.instance_id = i.id
      server.vpc_id = vpc.id
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
