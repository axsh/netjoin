# -*- coding: utf-8 -*-

require_relative 'base'
require_relative '../../interfaces/linux'

module DucttapeCLI
    
  class Linux < Base
    
    @type = 'linux'
    
    desc "add <name> <ip> <username> <password> <cert_path>","Add a new linux instance"
    def add(name, ip, username, password, cert_path)

      if(!File.file?(cert_path))
        puts "ERROR : not able to read certificate file at '#{cert_path}'" 
        return
      end
      
      # Read config file
      Struct.new("Data", :ip, :username, :password)
      Struct.new("Instance", :type, :data)
      config = YAML.load_file('config.yml')

      # Check for existing instance
      if(config[name])
        puts "ERROR : instance with name '#{name}' already exists" 
        return
      end      

      # Create Instance object to work with
      instance = Ducttape::Instances::Linux.new(name, ip, username, password)

      # Check for OpenVPN installation on the instance
      if(!Ducttape::Interfaces::Linux.checkOpenVpnInstalled(instance))
        puts "OpenVPN not installed, aborting!"
        return
      end

      if(!Ducttape::Interfaces::Linux.installCertificate(instance, cert_path))
        puts "OpenVPN certificate not installed, aborting!"
        return
      end
      
      # Update the config file
      data = Struct::Data.new(ip, username, password)
      instance = Struct::Instance.new(@type, data)
      config[name] = instance
      File.open('config.yml','w') do |h| 
        h.write config.to_yaml      
      end
    end
    
    desc "update <name>", "Update a linux instance"
    options :type => :string
    options :ip => :string
    options :username => :string
    options :password => :string
    def update(name)

      # Read config file
      Struct.new("Data", :ip, :username, :password)
      Struct.new("Instance", :type, :data)
      config = YAML.load_file('config.yml')

      # Check for existing instance
      if(!config[name])
        puts "ERROR : instance with name '#{name}' doest not exist" 
        return
      end

      # Update the config file
      if (options[:ip])
        config[name]["data"]["ip"] = options[:ip]
      end
      if (options[:username])
        config[name]["data"]["username"] = options[:username]
      end
      if (options[:password])
        config[name]["data"]["password"] = options[:password]
      end
      File.open('config.yml','w') do |h| 
        h.write config.to_yaml      
      end
    end

  end
end