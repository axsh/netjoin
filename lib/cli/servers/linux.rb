# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

require_relative 'base'

module DucttapeCLI::Server

  class Linux < Base

    desc "add <name>","Add server"
    option :ip_address, :required => true
    option :username, :required => true
    option :password, :required => true
    def add(name)
     
      # Read config file
      config = DucttapeCLI.loadConfig()

      # Check for existing instance
      if (config['servers'] and config['servers'][name])
        puts "ERROR : server with name '#{name}' already exists" 
        return
      end      

      # Create Instance object to work with
      instance = Ducttape::Instances::Linux.new(name, options[:ip_address], options[:username], options[:password])

      # Check for OpenVPN installation on the instance
      if (!Ducttape::Interfaces::Linux.checkOpenVpnInstalled(instance))
        puts "OpenVPN not installed on the server, aborting!"
        return
      end
      
      # Update the config file
      if(!config['servers'])
        config['servers'] = {}
      end  
      config['servers'][instance.name()] = instance.export()

      DucttapeCLI.writeConfig(config)
    end
    
    desc "update <name>", "Update server"
    options :name => :string
    options :ip_address => :string
    options :username => :string
    options :password => :string
    def update(name)
      # Read config file
      config = DucttapeCLI.loadConfig()

      # Check for existing instance
      if (!config['servers'] or !config['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist" 
        return
      end

      data = config['servers'][instance.name()][:data]

      instance = Ducttape::Instances::Linux.new(name, data[:ip_address], data[:username], data[:password])
      
      # Update the config file
      if (options[:ip])
        instance.ip_address = options[:ip] 
      end
      if (options[:username])
        instance.username = options[:username]
      end
      if (options[:password])
        instance.password = options[:password]
      end
      config['servers'][instance.name()] = instance.export()
      DucttapeCLI.writeConfig(config)
    end
        
   end
end