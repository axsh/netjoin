# -*- coding: utf-8 -*-

require_relative 'base'
require_relative '../../models/servers/softlayer'
require_relative '../../interfaces/softlayer'

module Netjoin::Cli::Server

  class Softlayer < Base

    @type = 'softlayer'

    desc "add <name>","Add a new Softlayer server"
    option :configured, :type => :string
    option :domain, :type => :string
    option :file_ca_crt, :type => :string
    option :file_conf, :type => :string
    option :file_crt, :type => :string
    option :file_key, :type => :string
    option :file_pem, :type => :string
    option :hostname, :type => :string
    option :installed, :type => :string
    option :key_pem, :type => :string
    option :password, :type => :string
    option :port, :type => :string, :required => true
    option :ssl_api_key, :type => :string, :required => true
    option :ssl_api_username, :type => :string, :required => true
    option :username, :type => :string
    def add(name)
      # Read database file
      database = Netjoin::Cli::Root.load_database()

      # Check for existing server
      if (database['servers'] and database['servers'][name])
        puts "ERROR : server with name '#{name}' already exists"
        return
      end

      # Check for a way to log in
      if(installed and Netjoin::Helpers::StringUtils.blank?(options[:password]) and Netjoin::Helpers::StringUtils.blank?(options[:key_pem]))
        puts "ERROR : Missing a password or pem key file to ssh/scp"
        return
      end

      # Create Server object to work with
      server = Netjoin::Models::Servers::Softlayer.new(name, options[:ssl_api_key], options[:ssl_api_username])

      if (options[:configured])
        if(options[:configured] === "false")
          server.configured = false
        else
          server.configured = true
        end
      end
      server.domain = options[:domain] if options[:domain]
      server.file_ca_crt = options[:file_ca_crt] if options[:file_ca_crt]
      server.file_conf = options[:file_conf] if options[:file_conf]
      server.file_crt = options[:file_crt] if options[:file_crt]
      server.file_key = options[:file_key] if options[:file_key]
      server.file_pem = options[:file_pem] if options[:file_pem]
      server.hostname = options[:hostname] if options[:hostname]
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
      server.ssl_api_key = options[:ssl_api_key] if options[:ssl_api_key]
      server.ssl_api_username = options[:ssl_api_username] if options[:ssl_api_username]
      server.username = options[:username] if options[:username]

      # Update the database file
      if(!database['servers'])
        database['servers'] = {}
      end
      database['servers'][server.name()] = server.export()

      Netjoin::Cli::Root.write_database(database)

      puts server.export_yaml
    end

    desc "update <name>", "Update an Softlayer server"
    option :configured, :type => :string
    option :domain, :type => :string
    option :file_ca_crt, :type => :string
    option :file_conf, :type => :string
    option :file_crt, :type => :string
    option :file_key, :type => :string
    option :file_pem, :type => :string
    option :hostname, :type => :string
    option :installed, :type => :string
    option :key_pem, :type => :string
    option :password, :type => :string
    option :port, :type => :string
    option :ssl_api_key, :type => :string
    option :ssl_api_username, :type => :string
    option :username, type => :string
    def update(name)
      # Read database file
      database = Netjoin::Cli::Root.load_database()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist"
        return
      end

      # Get server
      info = database['servers'][name]
      server = Netjoin::Models::Servers::Softlayer.retrieve(name, info)

      # Update the database file
      if (options[:configured])
        if(options[:configured] === "false")
          server.configured = false
        else
          server.configured = true
        end
      end
      server.domain = options[:domain] if options[:domain]
      server.file_ca_crt = options[:file_ca_crt] if options[:file_ca_crt]
      server.file_conf = options[:file_conf] if options[:file_conf]
      server.file_crt = options[:file_crt] if options[:file_crt]
      server.file_key = options[:file_key] if options[:file_key]
      server.file_pem = options[:file_pem] if options[:file_pem]
      server.hostname = options[:hostname] if options[:hostname]
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
      if(Netjoin::Helpers::StringUtils.blank?(server.password) and Netjoin::Helpers::StringUtils.blank?(server.key_pem))
        puts "ERROR : Missing a password or pem key file to ssh/scp"
        return
      end

      # Write database file
      database['servers'][server.name()] = server.export()
      Netjoin::Cli::Root.write_database(database)

      puts server.export_yaml
    end

    desc "create <name>", "Create the server on SoftLayer"
    def create(name)
      # Read database file
      database = Netjoin::Cli::Root.load_database()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist"
        return
      end

      # Get server
      info = database['servers'][name]
      server = Netjoin::Models::Servers::Softlayer.retrieve(name, info)

      if(server.installed)
        puts "Already installed"
        return
      end

      if(!server.instance_id)
        if(!Netjoin::Interfaces::Softlayer.create(server))
          puts "ERROR: something went wrong"
        end
      else
        puts " Softlayer instance already created, continuing"
      end

      # Write database file
      database['servers'][server.name()] = server.export()
      Netjoin::Cli::Root.write_database(database)

      softlayer_server = Netjoin::Interfaces::Softlayer.getServer(server)

      # Retrieving IP address
      if(!server.ip_address)
        puts "Checking for IP address, abort by ctrl-c, rerun command to continue."
        while(softlayer_server["primaryIpAddress"] == nil) do
          puts "No IP address found, checking every 5 seconds!"
          sleep(5)
          softlayer_server = Netjoin::Interfaces::Softlayer.show(server)
        end
        server.ip_address = softlayer_server["primaryIpAddress"]
        puts "  IP address found!"
        # Write database file
        database['servers'][server.name()] = server.export()
        Netjoin::Cli::Root.write_database(database)
      end

      if(!server.password or !server.username)
        puts "Fetching username and password"
        account = softlayer_server["operatingSystem"]["passwords"][0]
        server.password = account["password"]
        server.username = account["username"]
        if(!server.password)
          puts "  ERROR : no password"
          return
        end
        puts "  Username and password found!"
        # Write database file
        database['servers'][server.name()] = server.export()
        Netjoin::Cli::Root.write_database(database)
      end

      server.installed = true

      # Write database file
      database['servers'][server.name()] = server.export()
      Netjoin::Cli::Root.write_database(database)

      puts "Server created!"
    end

    desc "install <name>", "Install and configure server"
    def install(name)
      # Read database file
      database = Netjoin::Cli::Root.load_database()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist"
        return
      end

      info = database['servers'][name]
      server = Netjoin::Models::Servers::Softlayer.retrieve(name, info)

      # Check OpenVPN installation, install if missing
      puts "Checking epel-release installation"
      if (!server.installed or !Netjoin::Interfaces::Softlayer.check_epel_installed(server))
        puts "  Not installed, installing now"
        if (Netjoin::Interfaces::Softlayer.install_epel(server))
          puts "    Installed!"
        else
          puts "ERROR: Installation failed!"
        end
      else
        puts "  Already installed!"
      end

      # Check OpenVPN installation, install if missing
      puts "Checking OpenVPN installation"
      if (!server.installed or !Netjoin::Interfaces::Softlayer.check_openvpn_installed(server))
        puts "  Not installed, installing now"
        if (Netjoin::Interfaces::Softlayer.install_openvpn(server))
          puts "    Installed!"
          server.installed = true
        else
          puts "ERROR: Installation failed!"
          server.installed = false
        end
      else
        puts "  Already installed!"
      end

      # Save current progress
      database['servers'][name] = server.export()
      Netjoin::Cli::Root.write_database(database)

      # If installation failed, abort here
      if(!server.installed)
        puts "ERROR: Server not installed, aborting!"
        return
      end

      # If server is not yet configured, do it now
      if(!server.configured)
        puts "Configuring OpenVPN"
        error = false
        if(Netjoin::Interfaces::Softlayer.upload_openvpn_config(server))
          server.configured = true
          puts "  OpenVPN configured!"
        else
          puts "ERROR:  OpenVPN configuration failed!"
          return
        end
      else
        puts "OpenVPN already configured!"
      end

      # Save current progress
      database['servers'][name] = server.export()
      Netjoin::Cli::Root.write_database(database)

      puts "Restarting OpenVPN"
      if(Netjoin::Interfaces::Softlayer.restart_openvpn(server))
        puts "  OpenVPN restart : success!"
      else
        puts "  OpenVPN restart : failed!"
      end

      puts server.export_yaml
    end

    desc "describe <name>", "describe"
    def describe(name)
      # Read database file
      database = Netjoin::Cli::Root.load_database()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist"
        return
      end

      # Get server
      info = database['servers'][name]
      server = Netjoin::Models::Servers::Softlayer.retrieve(name, info)

      if (result = Netjoin::Interfaces::Softlayer.show(server))
        puts result.inspect
      else
        puts "ERROR: Server does not exist or something went wrong"
      end
    end

  end
end