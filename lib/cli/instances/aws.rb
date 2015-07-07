# -*- coding: utf-8 -*-

require_relative 'base'
require_relative '../../instances/aws'
require_relative '../../interfaces/aws'

module DucttapeCLI
    
  class Aws < Base
    
    @type = 'aws'
    
    desc "add <name> <region> <access_key> <secret_key>","Add a new AWS instance"
    def add(name, region, access_key, secret_key)

      # Read config file
      config = DucttapeCLI.loadConfig()

      # Check for existing instance
      if (config[name])
        puts "ERROR : instance with name '#{name}' already exists" 
        return
      end      

      # Create Instance object to work with
      instance = Ducttape::Instances::Aws.new(name, region, access_key, secret_key)
      
      Ducttape::Interfaces::Aws.createVpnGateway(instance)

      # Update the config file      
      config[instance.name()] = instance.export()     

      DucttapeCLI.writeConfig(config)
    end
    
    desc "update <name>", "Update an AWS instance"
    options :region => :string
    options :access_key => :string
    options :secret_key => :string
    def update(name)

      # Read config file
      config = DucttapeCLI.loadConfig()

      # Check for existing instance
      if (!config[name])
        puts "ERROR : instance with name '#{name}' doest not exist" 
        return
      end

      data = config[name][:data]

      instance = Ducttape::Instances::Aws.new(name, data[:access_key], data[:secret_key])

      # Update the config file
      if (options[:region])
        instance.secret_key = options[:region]
      end
      if (options[:access_key])
        instance.access_key = options[:access_key] 
      end
      if (options[:secret_key])
        instance.secret_key = options[:secret_key]
      end
      
      config[instance.name()] = instance.export()
      DucttapeCLI.writeConfig(config)
    end

  end

end