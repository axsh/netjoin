# -*- coding: utf-8 -*-

require_relative 'base'
require_relative '../../models/clients/linux'
require_relative '../../interfaces/linux'

module Ducttape::Cli::Client

  class Linux < Base

    @type = 'linux'

    desc "add <name>","Add a new linux client"
    option :generate_key, :type => :string
    option :ip_address, :type => :string, :required => true
    option :key_pem, :type => :string
    option :password, :type => :string
    option :server, :type => :string, :required => true
    option :username, :type => :string, :required => true
    option :vpn_ip_address, :type => :string
    def add(name)
      # Read database file
      database = Ducttape::Cli::Root.load_database()

      # Check for existing client
      if (database['clients'] and database['clients'][name])
        puts "ERROR : client with name '#{name}' already exists"
        return
      end

      # Check for a way to log in
      if(!options[:password] and !options[:key_pem])
        puts "ERROR : Missing a password or key file"
        return
      end

      # Create Client object to work with
      client = Ducttape::Models::Clients::Linux.new(name, options[:server], options[:ip_address], options[:username])
      client.generate_key = options[:generate_key]
      client.key_pem = options[:key_pem]
      client.password = options[:password]
      client.vpn_ip_address = options[:vpn_ip_address]

      # Update the database file
      if(!database['clients'])
        database['clients'] = {}
      end

      # Write database file
      database['clients'][client.name()] = client.export()
      Ducttape::Cli::Root.write_database(database)

      puts client.export_yaml()
    end

    desc "update <name>", "Update a linux client"
    option :generate_key, :type => :string
    option :ip_address, :type => :string
    option :key_pem, :type => :string
    option :password, :type => :string
    option :server, :type => :string
    option :username, :type => :string
    option :vpn_ip_address, :type => :string
    def update(name)
      # Read database file
      database = Ducttape::Cli::Root.load_database()

      # Check for existing client
      if (!database['clients'] or !database['clients'][name])
        puts "ERROR : client with name '#{name}' does not exist"
        return
      end

      # Get client
      info = database['clients'][name]
      client = Ducttape::Models::Clients::Linux.retrieve(name, info)

      # Update the database file
      if(options[:generate_key])
        client.generate_key = options[:generate_key]
      end
      if (options[:ip_address])
        client.ip_address = options[:ip_address]
      end
      if (options[:key_pem])
        client.key_pem = options[:key_pem]
      end
      if (options[:password])
        client.password = options[:password]
      end
      if (options[:server])
        client.server = options[:server]
      end
      if (options[:username])
        client.username = options[:username]
      end
      if(options[:vpn_ip_address])
        client.vpn_ip_address = options[:vpn_ip_address]
      end

      # Check for a way to log in
      if(!options[:password] and !options(:key_pem))
        puts "Missing a password or key file"
        return
      end

      # Write database file
      database['clients'][client.name()] = client.export()
      Ducttape::Cli::Root.write_database(database)

      puts client.export_yaml()
    end

  end

end