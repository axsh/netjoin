# -*- coding: utf-8 -*-

require_relative 'base'
require_relative '../../instances/linux'
require_relative '../../interfaces/linux'

module DucttapeCLI
    
  class Linux < Base
    
    @type = 'linux'
    
    desc "add <name> <ip> <username> <password> <cert_path>","Add a new linux instance"
    def add(name, ip, username, password, cert_path)

      if (!File.file?(cert_path))
        puts "ERROR : not able to read certificate file at '#{cert_path}'" 
        return
      end
      
      # Read config file
      config = DucttapeCLI.loadConfig()

      # Check for existing instance
      if (config[name])
        puts "ERROR : instance with name '#{name}' already exists" 
        return
      end      

      # Create Instance object to work with
      instance = Ducttape::Instances::Linux.new(name, ip, username, password)

      # Check for OpenVPN installation on the instance
      if (!Ducttape::Interfaces::Linux.checkOpenVpnInstalled(instance))
        puts "OpenVPN not installed, aborting!"
        return
      end

      if (!Ducttape::Interfaces::Linux.installCertificate(instance, cert_path))
        puts "OpenVPN certificate not installed, aborting!"
        return
      end
      
      # Update the config file      
      config[instance.name()] = instance.export()

      DucttapeCLI.writeConfig(config)
    end
    
    desc "update <name>", "Update a linux instance"
    options :type => :string
    options :ip => :string
    options :username => :string
    options :password => :string
    def update(name)

      # Read config file
      config = DucttapeCLI.loadConfig()

      # Check for existing instance
      if (!config[name])
        puts "ERROR : instance with name '#{name}' doest not exist" 
        return
      end

      data = config[name][:data]

      instance = Ducttape::Instances::Linux.new(name, data[:ip], data[:username], data[:password])
      
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
      config[instance.name()] = instance.export()
      DucttapeCLI.writeConfig(config)
    end

  end
end