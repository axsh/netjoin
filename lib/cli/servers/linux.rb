# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

require_relative 'base'

module DucttapeCLI::Server

  class Linux < Base
    
    @type = 'linux'

    desc "add <name>","Add server"
    option :ip_address, :required => true
    option :dns_mode
    option :dns_network
    option :username, :required => true
    option :password, :required => true
    def add(name)
     
      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()

      # Check for existing server
      if (database['servers'] and database['servers'][name])
        puts "ERROR : server with name '#{name}' already exists"
        return
      end      

      # Create server object to work with
      server = Ducttape::Servers::Linux.new(name, options[:ip_address], options[:username], options[:password], options[:dns_mode], options[:dns_network])

      # Check for OpenVPN installation on the server
      if (!server.ip_address === '0.0.0.0' and !Ducttape::Interfaces::Linux.checkOpenVpnInstalled(server))
        puts "OpenVPN not installed on the server, aborting!"
        return
      end
      
      # Update the database file
      if(!database['servers'])
        database['servers'] = {}
      end  
      database['servers'][server.name()] = server.export()

      DucttapeCLI::CLI.writeDatabase(database)
      
      puts server.export_yaml
    end
    
    desc "update <name>", "Update server"
    options :name => :string
    options :ip_address => :string
    option :dns_mode
    option :dns_network
    options :username => :string
    options :password => :string
    def update(name)
      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist" 
        return
      end

      info = database['servers'][name]

      server = Ducttape::Servers::Linux.retrieve(name, info)
      
      # Update the database file
      if (options[:ip_address])
        server.ip_address = options[:ip_address] 
      end
      if (options[:dns_mode])
        server.dns_mode = options[:dns_mode] 
      end
      if (options[:dns_network])
        server.dns_network = options[:dns_network] 
      end
      if (options[:username])
        server.username = options[:username]
      end
      if (options[:password])
        server.password = options[:password]
      end
      database['servers'][name] = server.export()
      
      DucttapeCLI::CLI.writeDatabase(database)
      
      puts server.export_yaml
    end
        
   end
end