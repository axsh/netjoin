# -*- coding: utf-8 -*-

require_relative 'base'
require_relative '../../instances/linux'
require_relative '../../interfaces/linux'

module DucttapeCLI::Instance
    
  class Linux < Base
    
    @type = 'linux'
    
    desc "add <name>","Add a new linux instance"
    option :server, :required => true
    option :ip_address, :required => true
    option :username, :required => true
    option :password, :required => true
    def add(name)
      
      # Read config file
      config = DucttapeCLI.loadConfig()

      # Check for existing instance
      if (config['instances'] and config['instances'][name])
        puts "ERROR : instance with name '#{name}' already exists" 
        return
      end      

      # Create Instance object to work with
      instance = Ducttape::Instances::Linux.new(name, options[:server], options[:ip_address], options[:username], options[:password])
     
      # Update the config file
      if(!config['instances'])
        config['instances'] = {}
      end  
      config['instances'][instance.name()] = instance.export()

      DucttapeCLI.writeConfig(config)
    end
    
    desc "update <name>", "Update a linux instance"
    options :type => :string
    options :ip_address => :string
    options :username => :string
    options :password => :string
    def update(name)
      
      # Read config file
      config = DucttapeCLI.loadConfig()

      # Check for existing instance
      if (!config['instances'] or !config['instances'][name])
        puts "ERROR : instance with name '#{name}' does not exist" 
        return
      end

      data = config['instances'][name][:data]

      instance = Ducttape::Instances::Linux.new(name, data[:ip_address], data[:username], data[:password])
      instance.status = config['instances'][:status]
      
      # Update the config file
      if (options[:ip_address])
        instance.ip_address = options[:ip_address] 
      end
      if (options[:username])
        instance.username = options[:username]
      end
      if (options[:password])
        instance.password = options[:password]
      end
      config['instances'][instance.name()] = instance.export()
      DucttapeCLI.writeConfig(config)
    end

  end

end