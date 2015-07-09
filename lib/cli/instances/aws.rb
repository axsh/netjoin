# -*- coding: utf-8 -*-

require_relative 'base'
require_relative '../../instances/aws'
require_relative '../../interfaces/aws'

module DucttapeCLI
    
  class Aws < Base
    
    @type = 'aws'
    
    desc "add <name> <region> <vpc> <ip_address> <access_key> <secret_key>","Add a new AWS instance"
    def add(name, region, vpc, ip_address, access_key, secret_key)

      # Read config file
      config = DucttapeCLI.loadConfig()

      # Check for existing instance
      if (config['instances'] and config['instances'][name])
        puts "ERROR : instance with name '#{name}' already exists" 
        return
      end      

      # Create Instance object to work with
      instance = Ducttape::Instances::Aws.new(name, region, vpc, ip_address, access_key, secret_key)
      
      puts "Creating VPN Gateway"
      Ducttape::Interfaces::Aws.createVpnGateway(instance)
      puts "Attaching VPC to VPN Gateway"
      Ducttape::Interfaces::Aws.attachVpc(instance)
      puts "Creating Customer Gateway"
      Ducttape::Interfaces::Aws.createCustomerGateway(instance)

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