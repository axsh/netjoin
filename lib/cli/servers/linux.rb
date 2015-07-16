# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

require_relative 'base'

module DucttapeCLI::Server

  class Linux < Base
    
    @type = 'linux'

    desc "add <name>","Add server"
    option :ip_address, :required => true
    option :mode, :required => true
    option :network, :required => true
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
      server = Ducttape::Servers::Linux.new(name, options[:ip_address], options[:username], options[:password], options[:mode], options[:network])

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
    option :name => :string
    option :ip_address => :string
    option :mode => :string
    option :network => :string
    option :username => :string
    option :password => :string
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
      if (options[:mode])
        server.mode = options[:mode] 
      end
      if (options[:network])
        server.network = options[:network] 
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