# -*- coding: utf-8 -*-

require_relative 'base'
require_relative '../../models/servers/softlayer'
require_relative '../../interfaces/softlayer'

module Ducttape::Cli::Server

  class Softlayer < Base

    @type = 'softlayer'

    desc "add <name>","Add a new Softlayer server"
    option :configured, :type => :string
    option :file_ca_crt, :type => :string
    option :file_conf, :type => :string
    option :file_crt, :type => :string
    option :file_key, :type => :string
    option :file_pem, :type => :string
    option :installed, :type => :string
    option :key_pem, :type => :string
    option :password, :type => :string
    option :port, :type => :string, :required => true
    option :ssl_api_key, :type => :string, :required => true
    option :ssl_api_username, :type => :string, :required => true
    option :username, :type => :string
    def add(name)
      # Read database file
      database = Ducttape::Cli::Root.load_database()

      # Check for existing server
      if (database['servers'] and database['servers'][name])
        puts "ERROR : server with name '#{name}' already exists"
        return
      end

      # Check for a way to log in
      if(Ducttape::Helpers::StringUtils.blank?(options[:password]) and Ducttape::Helpers::StringUtils.blank?(options[:key_pem]))
        puts "ERROR : Missing a password or pem key file to ssh/scp"
        return
      end

      # Create Server object to work with
      server = Ducttape::Models::Servers::Softlayer.new(name,
        []
      )

      if (options[:configured])
        if(options[:configured] === "false")
          server.configured = false
        else
          server.configured = true
        end
      end
      server.file_ca_crt = options[:file_ca_crt] if options[:file_ca_crt]
      server.file_conf = options[:file_conf] if options[:file_conf]
      server.file_crt = options[:file_crt] if options[:file_crt]
      server.file_key = options[:file_key] if options[:file_key]
      server.file_pem = options[:file_pem] if options[:file_pem]
      if (options[:installed])
        if(options[:installed] === "false")
          server.installed = false
        else
          server.installed = true
        end
      end
      server.key_pem = options[:key_pem] if options[:key_pem]
      server.password = options[:password] if options[:password]
      server.port = options[:port] if options[:port]
      server.port = options[:ssl_api_key] if options[:ssl_api_key]
      server.port = options[:ssl_api_username] if options[:ssl_api_username]
      server.password = options[:username] if options[:username]

      # Update the database file
      if(!database['servers'])
        database['servers'] = {}
      end
      database['servers'][server.name()] = server.export()

      Ducttape::Cli::Root.write_database(database)

      puts server.export_yaml
    end

    desc "update <name>", "Update an Softlayer server"
    option :configured, :type => :string
    option :file_ca_crt, :type => :string
    option :file_conf, :type => :string
    option :file_crt, :type => :string
    option :file_key, :type => :string
    option :file_pem, :type => :string
    option :installed, :type => :string
    option :key_pem, :type => :string
    option :password, :type => :string
    option :port, :type => :string
    option :ssl_api_key, :type => :string
    option :ssl_api_username, :type => :string
    option :username, type => :string
    def update(name)
      # Read database file
      database = Ducttape::Cli::Root.load_database()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist"
        return
      end

      # Get server
      info = database['servers'][name]
      server = Ducttape::Models::Servers::Softlayer.retrieve(name, info)

      # Update the database file
      if (options[:configured])
        if(options[:configured] === "false")
          server.configured = false
        else
          server.configured = true
        end
      end
      server.file_ca_crt = options[:file_ca_crt] if options[:file_ca_crt]
      server.file_conf = options[:file_conf] if options[:file_conf]
      server.file_crt = options[:file_crt] if options[:file_crt]
      server.file_key = options[:file_key] if options[:file_key]
      server.file_pem = options[:file_pem] if options[:file_pem]
      if (options[:installed])
        if(options[:installed] === "false")
          server.installed = false
        else
          server.installed = true
        end
      end
      server.key_pem = options[:key_pem] if options[:key_pem]
      server.password = options[:password] if options[:password]
      server.port = options[:port] if options[:port]
      server.port = options[:ssl_api_key] if options[:ssl_api_key]
      server.port = options[:ssl_api_username] if options[:ssl_api_username]
      server.username = options[:username] if options[:username]

      # Check for a way to log in
      if(Ducttape::Helpers::StringUtils.blank?(server.password) and Ducttape::Helpers::StringUtils.blank?(server.key_pem))
        puts "ERROR : Missing a password or pem key file to ssh/scp"
        return
      end

      # Write database file
      database['servers'][server.name()] = server.export()
      Ducttape::Cli::Root.write_database(database)

      puts server.export_yaml
    end

  end
end