# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

require_relative 'base'

module DucttapeCLI::Server

  class Linux < Base
    
    @type = 'linux'

    desc "add <name>","Add server"
    option :ip_address, :required => true
    option :username, :required => true
    option :password, :required => true
    def add(name)
     
      # Read database file
      database = DucttapeCLI.loadDatabase()

      # Check for existing server
      if (database['servers'] and database['servers'][name])
        puts "ERROR : server with name '#{name}' already exists" 
        return
      end      

      # Create server object to work with
      server = Ducttape::Servers::Linux.new(name, options[:ip_address], options[:username], options[:password])

      # Check for OpenVPN installation on the server
      if (!Ducttape::Interfaces::Linux.checkOpenVpnInstalled(server))
        puts "OpenVPN not installed on the server, aborting!"
        return
      end
      
      # Update the database file
      if(!database['servers'])
        database['servers'] = {}
      end  
      database['servers'][server.name()] = server.export()

      DucttapeCLI.writeDatabase(database)
    end
    
    desc "update <name>", "Update server"
    options :name => :string
    options :ip_address => :string
    options :username => :string
    options :password => :string
    def update(name)
      # Read database file
      database = DucttapeCLI.loadDatabase()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist" 
        return
      end

      data = database['servers'][name][:data]

      server = Ducttape::Servers::Linux.new(name, data[:ip_address], data[:username], data[:password])
      
      # Update the database file
      if (options[:ip])
        server.ip_address = options[:ip] 
      end
      if (options[:username])
        server.username = options[:username]
      end
      if (options[:password])
        server.password = options[:password]
      end
      database['servers'][name] = server.export()
      DucttapeCLI.writeDatabase(database)
    end
        
   end
end