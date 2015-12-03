# -*- coding: utf-8 -*-

require 'aws-sdk'

module Netjoin::Drivers
  module Aws
    extend Netjoin::Helpers::Logger

    def self.create(node)
      required_params = [
        :ami,
        :instance_type,
        :key_pair,
      ]

      required_params.each do |param|
        next if node.__send__(param)
        error "Missing param #{param}"
        return
      end

      ::Aws.config.update({
        region: node.region,
        credentials: ::Aws::Credentials.new(node.access_key_id, node.secret_key)
      })
      ec2 = ::Aws::EC2::Client.new

      vpc_id = ""
      subnet_id = ""
      route_table_id = ""
      igw_id = ""
      secg_id = ""

      vpc_cidr = node.vpc_cidr
      subnet_cidr = node.subnet_cidr

      image_id = node.ami

      if vpc_id == ""
        vpc_id = ec2.create_vpc(
          cidr_block: vpc_cidr,
          instance_tenancy: "default",
        ).vpc.vpc_id
        info "Create VPC #{vpc_id}"
      end
      vpc = ::Aws::EC2::Vpc.new(id: vpc_id)

      if subnet_id == ""
        subnet_id = ec2.create_subnet(
          vpc_id: vpc_id,
          cidr_block: subnet_cidr,
        ).subnet.subnet_id
        info "Create subnet #{subnet_id}"
      end
      subnet = ::Aws::EC2::Subnet.new(id: subnet_id)

      if route_table_id == ""
        route_table_id = ec2.describe_route_tables(
          filters: [
            { name: "vpc-id", values: [vpc_id] }
          ]
        ).route_tables.first.route_table_id
        info "Create route table #{route_table_id}"
      end

      ec2.associate_route_table({
        subnet_id: subnet_id,
        route_table_id: route_table_id
      })

      if igw_id == ""
        igw_id = ec2.create_internet_gateway.internet_gateway.internet_gateway_id
      end
      igw = ::Aws::EC2::InternetGateway.new(id: igw_id)
      info "Create igw #{igw_id}"

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
      secg = ::Aws::EC2::SecurityGroup.new(id: secg_id)
      info "Create secg #{secg_id}"

      if secg.data.ip_permissions.empty?
        secg.authorize_ingress(ip_permissions: [{ip_protocol: "-1", from_port: nil, to_port: nil, user_id_group_pairs: [{group_id: "#{secg.id}"}]}])

        Netjoin.config['global_cidrs'].each do |global_cidr|
          secg.authorize_ingress(ip_permissions: [{ip_protocol: "-1", from_port: nil, to_port: nil, ip_ranges: [{cidr_ip: "#{global_cidr}"}]}])
          secg.authorize_egress(ip_permissions: [{ip_protocol: "-1", from_port: nil, to_port: nil, ip_ranges: [{cidr_ip: "#{global_cidr}"}]}])
        end
      end
      secg.load
      info "Create rules #{secg.data}"

      instance_id = ec2.run_instances({
        image_id: image_id,
        min_count: 1,
        max_count: 1,
        key_name: node.key_pair,
        instance_type: node.instance_type,
        network_interfaces: [
          { device_index: 0, associate_public_ip_address: true, subnet_id: subnet_id, groups: [secg_id] }
        ]
      }).instances.first.instance_id
      i = ::Aws::EC2::Instance.new(id: instance_id)
      info "Create instance #{instance_id}"
      i.wait_until_running

      node.instance_id = i.id
      node.vpc_id = vpc.id
      node.security_groups = i.data.security_groups.map(&:group_id)
      node.public_ip_address = i.data.public_ip_address
      node.save
    end
  end
end
