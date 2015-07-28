# -*- coding: utf-8 -*-

require "right_aws_api"

require_relative 'base'

module Ducttape::Interfaces

  class Aws < Base

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

      puts response.to_yaml()

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

      puts response.to_yaml()

      instance = response["DescribeInstancesResponse"]["reservationSet"]["item"]["instancesSet"]["item"]
      server.ip_address = instance["ipAddress"]
      server.public_dns_name = instance["dnsName"]
      if(!server.ip_address or !server.public_dns_name)
        return false
      end
      return true
    end

     def self.move_file(client, source, destination)
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        ssh.open_channel do |channel|
          channel.request_pty do |ch, success|
            if success
              puts "Successfully obtained pty"
            else
              puts "Could not obtain pty"
            end
          end

          channel.exec("sudo mv #{source} #{destination}") do |ch, success|
            abort "Could not execute commands!" unless success
            channel.on_data do |ch, data|
              puts ch.exec("sudo ls /etc/openvpn")
            end
            channel.on_extended_data do |ch, type, data|
              puts "stderr: #{data}"
            end
          end
        end
      end
    end

    def self.check_openvpn_installed(client)
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        result = ssh.exec!('rpm -qa | grep openvpn')
        if (result)
          return true
        end
      end
      return false
    end

    def self.install_openvpn(client)
      installed = false
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        ssh.open_channel do |channel|
          channel.request_pty do |ch, success|
            if success
              puts "Successfully obtained pty"
            else
              puts "Could not obtain pty"
            end
          end

          channel.exec('sudo yum install -y openvpn') do |ch, success|
            abort "Could not execute commands!" unless success
            channel.on_data do |ch, data|
              if (data.include?("Complete!") or data.include?("Nothing to do"))
                installed = true
              end
            end
            channel.on_extended_data do |ch, type, data|
              puts "stderr: #{data}"
            end
          end
        end
      end
      return installed
    end

    def self.install_certificate(client)
      return Base.upload_file(client, "keys/#{client.name}.ovpn", "/etc/openvpn/#{client.name}.ovpn")
    end

    def self.start_openvpn_server(client)
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        ssh.exec!("sudo service openvpn restart")
        return true
      end
      return false
    end
  end

end