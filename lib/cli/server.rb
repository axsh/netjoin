# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

module DucttapeCLI

  class Server < Thor

    desc "show","Show server"
    def show()

      # Read config file
      config = DucttapeCLI.loadConfig()

      # If specific instance is asked, show that instance only, if not, show all
      if(config['server'])
        puts config['server'].inspect
      end
      
    end

    desc "add <ip> <username> <password>","Add server"
    def add(ip, username, password)
     
      # Read config file
      config = DucttapeCLI.loadConfig()

      # Check for existing instance
      if (config['server'])
        puts "ERROR : server already exists" 
        return
      end      

      # Create Instance object to work with
      instance = Ducttape::Instances::Linux.new('server', ip, username, password)

      # Check for OpenVPN installation on the instance
      if (!Ducttape::Interfaces::Linux.checkOpenVpnInstalled(instance))
        puts "OpenVPN not installed on the server, aborting!"
        return
      end
      
      # Update the config file
      if(!config['server'])
        config['server'] = {}
      end  
      config['server'] = instance.export()

      DucttapeCLI.writeConfig(config)
    end
    
    desc "update ", "Update server"
    options :name => :string
    options :ip => :string
    options :username => :string
    options :password => :string
    def update(name)
      # Read config file
      config = DucttapeCLI.loadConfig()

      # Check for existing instance
      if (!config['server'])
        puts "ERROR : server does not exist" 
        return
      end

      data = config['server'][:data]

      instance = Ducttape::Instances::Linux.new('server', data[:ip], data[:username], data[:password])
      
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
      config['server'] = instance.export()
      DucttapeCLI.writeConfig(config)
    end
        
   end
end