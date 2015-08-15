# -*- coding: utf-8 -*-

require_relative 'base'

module Netjoin::Cli::Server

  class Linux < Base

    @type = 'linux'

    desc "add <name>","Add server"
    option :mode, :type => :string, :required => true
    option :master, :type => :string
    option :configured, :type => :string
    option :file_ca_crt, :type => :string
    option :file_conf, :type => :string
    option :file_crt, :type => :string
    option :file_key, :type => :string
    option :file_pem, :type => :string
    option :key_pem, :type => :string
    option :psk, :type => :string
    option :installed, :type => :string
    option :ip_address, :type => :string, :required => true
    option :mode, :type => :string
    option :network_ip, :type => :string
    option :network_prefix, :type => :string
    option :password, :type => :string
    option :port, :type => :string
    option :username, :type => :string, :required => true
    def add(name)
      # Read database file
      database = Netjoin::Cli::Root.load_database()

      # Check for existing server
      if (database['servers'] and database['servers'][name])
        puts "ERROR : server with name '#{name}' already exists"
        return
      end

      if(Netjoin::Helpers::StringUtils.blank?(options[:password]) and Netjoin::Helpers::StringUtils.blank?(options[:key_pem]))
        puts "ERROR : Missing a password or pem key file to ssh/scp"
        return
      end

      if(!Netjoin::Helpers::StringUtils.blank?(options[:ip_address]) and !Netjoin::Helpers::StringUtils.valid_ip_address?(options[:ip_address]))
        puts "ERROR : Not a valid IP address!"
        return
      end

      if(!Netjoin::Helpers::StringUtils.blank?(options[:network_ip]) and !Netjoin::Helpers::StringUtils.valid_ip_address?(options[:network_ip]))
        puts "ERROR : Not a valid network IP address!"
        return
      end

      unless options[:mode] == "site-to-site" || options[:mode] == "client-to-client"
        puts "ERROR : invalid mode #{options[:mode]}"
        return
      end

      # Create server object to work with
      server = Netjoin::Models::Servers::Linux.new(name, options[:ip_address], options[:username])

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
      server.key_pem = options[:key_pem] if options[:key_pem]
      server.psk = options[:psk] if options[:psk]
      if (options[:installed])
        if(options[:installed] === "false")
          server.installed = false
        else
          server.installed = true
        end
      end
      server.mode = options[:mode] if options[:mode]
      server.master = options[:master] if options[:master]
      server.network_ip = options[:network_ip] if options[:network_ip]
      server.network_prefix = options[:network_prefix] if options[:network_prefix]
      server.password = options[:password] if options[:password]
      server.port = options[:port] if options[:port]

      # Check for OpenVPN installation on the server
      if (!server.ip_address === '0.0.0.0' and !Netjoin::Interfaces::Linux.check_openvpn_installed(server))
        puts "OpenVPN not installed on the server, aborting!"
        return
      end

      # Update the database file
      if(!database['servers'])
        database['servers'] = {}
      end
      database['servers'][server.name()] = server.export()
      Netjoin::Cli::Root.write_database(database)

      puts server.export_yaml
    end

    desc "update <name>", "Update server"
    option :configured, :type => :string
    option :file_ca_crt, :type => :string
    option :file_conf, :type => :string
    option :file_crt, :type => :string
    option :file_key, :type => :string
    option :file_pem, :type => :string
    option :key_pem, :type => :string
    option :installed, :type => :string
    option :ip_address, :type => :string
    option :mode, :type => :string
    option :network_ip, :type => :string
    option :network_prefix, :type => :string
    option :password, :type => :string
    option :port, :type => :string
    option :username, :type => :string
    def update(name)
      # Read database file
      database = Netjoin::Cli::Root.load_database()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist"
        return
      end

      info = database['servers'][name]
      server = Netjoin::Models::Servers::Linux.retrieve(name, info)

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
      server.key_pem = options[:key_pem] if options[:key_pem]
      if (options[:installed])
        if(options[:installed] === "false")
          server.installed = false
        else
          server.installed = true
        end
      end
      server.ip_address = options[:ip_address] if options[:ip_address]
      server.mode = options[:mode] if options[:mode]
      server.network_ip = options[:network_ip] if options[:network_ip]
      server.network_prefix = options[:network_prefix] if options[:network_prefix]
      server.password = options[:password] if options[:password]
      server.port = options[:port] if options[:port]
      server.username = options[:username] if options[:username]

      if(Netjoin::Helpers::StringUtils.blank?(server.password) and Netjoin::Helpers::StringUtils.blank?(server.key_pem))
        puts "ERROR : Missing a password or pem key file to ssh/scp"
        return
      end

      if(!Netjoin::Helpers::StringUtils.blank?(server.ip_address) and !Netjoin::Helpers::StringUtils.valid_ip_address?(server.ip_address))
        puts "ERROR : Not a valid IP address!"
        return
      end

      if(!Netjoin::Helpers::StringUtils.blank?(server.network_ip) and !Netjoin::Helpers::StringUtils.valid_ip_address?(server.network_ip))
        puts "ERROR : Not a valid network IP address!"
        return
      end

      database['servers'][name] = server.export()
      Netjoin::Cli::Root.write_database(database)

      puts server.export_yaml
    end

    desc "install <name>", "Install and configure server"
    def install(name)
      database = Netjoin::Cli::Root.load_database()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist"
        return
      end

      info = database['servers'][name]

      server = Netjoin::Models::Servers::Linux.retrieve(name, info)

      puts "Checking OpenVPN Installation"
      if (!Netjoin::Interfaces::Linux.check_openvpn_installed(server))
        if (Netjoin::Interfaces::Linux.install_openvpn(server))
          puts "  OpenVPN installed!"
          server.installed = true
        else
          puts "ERROR:  OpenVPN installation failed!"
          server.installed = false
        end
      else
        puts "  OpenVPN already installed!"
        server.installed = true
      end

      database['servers'][name] = server.export()
      Netjoin::Cli::Root.write_database(database)

      if(!server.configured)
        puts "Configuring OpenVPN"
        error = false
        if(Netjoin::Interfaces::Linux.upload_openvpn_config(server, database))
          server.configured = true
          puts "  OpenVPN configured!"
        else
          puts "ERROR:  OpenVPN configuration failed!"
          return
        end
      else
        puts "OpenVPN already configured!"
      end

      database['servers'][name] = server.export()
      Netjoin::Cli::Root.write_database(database)

      if(!error)
        puts "Starting OpenVPN with config"
        Netjoin::Interfaces::Linux.restart_openvpn(server)
        Netjoin::Interfaces::Linux.start_openvpn_config(server)
        Netjoin::Interfaces::Linux.restart_openvpn(server)
      else
        raise Exception.new("Something went wrong")
      end

    end
  end
end
