# -*- coding: utf-8 -*-

require_relative 'base'
require_relative '../../instances/aws'
require_relative '../../interfaces/aws'

module DucttapeCLI::Instance
    
  class Aws < Base
    
    @type = 'aws'
    
    desc "add <name>","Add a new AWS instance"
    option :region, :required => true
    option :vpc, :required => true
    option :ip_address, :required => true
    option :access_key, :required => true
    option :secret_key, :required => true
    def add(name)

      # Read config file
      config = DucttapeCLI.loadConfig()

      # Check for existing instance
      if (config['instances'] and config['instances'][name])
        puts "ERROR : instance with name '#{name}' already exists" 
        return
      end      

      # Create Instance object to work with
      instance = Ducttape::Instances::Aws.new(name, options[:region], options[:vpc], options[:ip_address], options[:access_key], options[:secret_key])

      puts "Creating VPN Gateway"
      Ducttape::Interfaces::Aws.createVpnGateway(instance)
      puts "Attaching VPC to VPN Gateway"
      Ducttape::Interfaces::Aws.attachVpc(instance)
      puts "Creating Customer Gateway"
      # TODO support other than linux servers 
      server_ip = config['servers'][instance.server][:data][:ip_address]
      Ducttape::Interfaces::Aws.createCustomerGateway(instance, server_ip)

      # Update the config file
      if(!config['instances'])
        config['instances'] = {}
      end  
      config['instances'][instance.name()] = instance.export()     

      DucttapeCLI.writeConfig(config)
    end
    
    desc "update <name>", "Update an AWS instance"
    options :region => :string
    options :vpc => :string
    options :access_key => :string
    options :secret_key => :string
    def update(name)

      # Read config file
      config = DucttapeCLI.loadConfig()

      # Check for existing instance
      if (!config['instances'] or !config['instances'][name])
        puts "ERROR : instance with name '#{name}' does not exist" 
        return
      end

      data = config['instances'][name][:data]

      instance = Ducttape::Instances::Aws.new(name, data[:access_key], data[:secret_key])

      # Update the config file
      if (options[:region])
        instance.secret_key = options[:region]
      end
      if (options[:vpc])
        instance.vpc = options[:vpc]
      end
      if (options[:access_key])
        instance.access_key = options[:access_key] 
      end
      if (options[:secret_key])
        instance.secret_key = options[:secret_key]
      end
      
      config['instances'][instance.name()] = instance.export()
      DucttapeCLI.writeConfig(config)
    end

  end

end