# -*- coding: utf-8 -*-

require_relative 'base'
require_relative '../../clients/linux'
require_relative '../../interfaces/linux'

module DucttapeCLI::Client
    
  class Linux < Base
    
    @type = 'linux'
    
    desc "add <name>","Add a new linux client"
    option :server, :required => true
    option :ip_address, :required => true
    option :username, :required => true
    option :password, :required => true
    option :vpn_ip_address, :required => true
    def add(name)
      
      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()

      # Check for existing client
      if (database['clients'] and database['clients'][name])
        puts "ERROR : client with name '#{name}' already exists" 
        return
      end      

      # Create Client object to work with
      client = Ducttape::Clients::Linux.new(name, options[:server], options[:ip_address], options[:username], options[:password], options[:vpn_ip_address])
     
      # Update the database file
      if(!database['clients'])
        database['clients'] = {}
      end

      database['clients'][client.name()] = client.export()

      DucttapeCLI::CLI.writeDatabase(database)

      puts client.export_yaml()
    end
    
    desc "update <name>", "Update a linux client"
    options :type => :string
    options :ip_address => :string
    options :username => :string
    options :password => :string
    options :vpn_ip_address => :string
    def update(name)
      
      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()

      # Check for existing client
      if (!database['clients'] or !database['clients'][name])
        puts "ERROR : client with name '#{name}' does not exist" 
        return
      end

      info = database['clients'][name]

      client = Ducttape::Clients::Linux.retrieve(name, info)
      
      # Update the database file
      if (options[:ip_address])
        client.ip_address = options[:ip_address] 
      end
      if (options[:username])
        client.username = options[:username]
      end
      if (options[:password])
        client.password = options[:password]
      end
      if (options[:vpn_ip_address])
        client.vpn_ip_address = options[:vpn_ip_address] 
      end

      database['clients'][client.name()] = client.export()

      DucttapeCLI::CLI.writeDatabase(database)

      puts client.export_yaml()
    end

  end

end