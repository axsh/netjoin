# -*- coding: utf-8 -*-

require_relative 'base'
require_relative '../../clients/linux'
require_relative '../../interfaces/linux'

module Ducttape::Cli::Client
    
  class Linux < Base
    
    @type = 'linux'
    
    desc "add <name>","Add a new linux client"
    option :server, :type => :string, :required => true
    option :ip_address, :type => :string, :required => true
    option :username, :type => :string, :required => true
    option :password, :type => :string, :required => true
    option :vpn_ip_address, :type => :string
    option :generate_key, :type => :string
    def add(name)
      
      # Read database file
      database = Ducttape::Cli::Root.loadDatabase()

      # Check for existing client
      if (database['clients'] and database['clients'][name])
        puts "ERROR : client with name '#{name}' already exists" 
        return
      end

      # Create Client object to work with
      client = Ducttape::Clients::Linux.new(name, options[:server], options[:ip_address], options[:username], options[:password])
      if(options[:vpn_ip_address])
        client.vpn_ip_address = options[:vpn_ip_address]
      end
      if(options[:generate_key])
        client.generate_key = options[:generate_key] 
      end
     
      # Update the database file
      if(!database['clients'])
        database['clients'] = {}
      end

      database['clients'][client.name()] = client.export()

      Ducttape::Cli::Root.writeDatabase(database)

      puts client.export_yaml()
    end
    
    desc "update <name>", "Update a linux client"
    option :server, :type => :string
    option :ip_address, :type => :string
    option :username, :type => :string
    option :password, :type => :string
    option :vpn_ip_address, :type => :string
    option :generate_key, :type => :string
    def update(name)
      
      # Read database file
      database = Ducttape::Cli::Root.loadDatabase()

      # Check for existing client
      if (!database['clients'] or !database['clients'][name])
        puts "ERROR : client with name '#{name}' does not exist" 
        return
      end

      info = database['clients'][name]

      client = Ducttape::Clients::Linux.retrieve(name, info)
      
      # Update the database file
      if (options[:server])
        client.server = options[:server] 
      end
      if (options[:ip_address])
        client.ip_address = options[:ip_address] 
      end
      if (options[:username])
        client.username = options[:username]
      end
      if (options[:password])
        client.password = options[:password]
      end
      if(options[:vpn_ip_address])
        client.vpn_ip_address = options[:vpn_ip_address]
      end
      if(options[:generate_key])
        client.generate_key = options[:generate_key] 
      end

      database['clients'][client.name()] = client.export()

      Ducttape::Cli::Root.writeDatabase(database)

      puts client.export_yaml()
    end

  end

end