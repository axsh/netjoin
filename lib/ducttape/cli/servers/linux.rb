# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Cli::Server

  class Linux < Base

    @type = 'linux'

    desc "add <name>","Add server"
    option :ip_address, :type => :string, :required => true
    option :mode, :type => :string, :required => true
    option :network, :type => :string, :required => true
    option :username, :type => :string, :required => true
    option :password, :type => :string, :required => true
    option :installed, :type => :boolean
    option :configured, :type => :boolean
    option :file_conf, :type => :string
    option :file_ca_crt, :type => :string
    option :file_pem, :type => :string
    option :file_crt, :type => :string
    option :file_key, :type => :string
    def add(name)

      # Read database file
      database = Ducttape::Cli::Root.load_database()

      # Check for existing server
      if (database['servers'] and database['servers'][name])
        puts "ERROR : server with name '#{name}' already exists"
        return
      end

      # Create server object to work with
      server = Ducttape::Models::Servers::Linux.new(name, options[:ip_address], options[:username], options[:mode], options[:network])

      server.password = options[:password]
      server.installed = options[:installed]
      server.configured = options[:configured]
      server.file_conf = options[:file_conf]
      server.file_ca_crt = options[:file_ca_crt]
      server.file_pem = options[:file_pem]
      server.file_crt = options[:file_crt]
      server.file_key = options[:file_key]

      # Check for OpenVPN installation on the server
      if (!server.ip_address === '0.0.0.0' and !Ducttape::Interfaces::Linux.check_openvpn_installed(server))
        puts "OpenVPN not installed on the server, aborting!"
        return
      end

      # Update the database file
      if(!database['servers'])
        database['servers'] = {}
      end
      database['servers'][server.name()] = server.export()

      Ducttape::Cli::Root.write_database(database)

      puts server.export_yaml
    end

    desc "update <name>", "Update server"
    option :name, :type => :string
    option :ip_address, :type => :string
    option :mode, :type => :string
    option :network, :type => :string
    option :username, :type => :string
    option :password, :type => :string
    option :installed, :type => :boolean
    option :configured, :type => :boolean
    option :file_conf, :type => :string
    option :file_ca_crt, :type => :string
    option :file_pem, :type => :string
    option :file_crt, :type => :string
    option :file_key, :type => :string
    def update(name)
      # Read database file
      database = Ducttape::Cli::Root.load_database()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist"
        return
      end

      info = database['servers'][name]

      server = Ducttape::Models::Servers::Linux.retrieve(name, info)

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
      if (options[:installed])
        server.installed = options[:installed]
      end
      if (options[:configured])
        server.configured = options[:configured]
      end
      if (options[:file_conf])
        server.file_conf = options[:file_conf]
      end
      if (options[:file_ca_crt])
        server.file_ca_crt = options[:file_ca_crt]
      end
      if (options[:file_pem])
        server.file_pem = options[:file_pem]
      end
      if (options[:file_crt])
        server.file_crt = options[:file_crt]
      end
      if (options[:file_key])
        server.file_key = options[:file_key]
      end

      database['servers'][name] = server.export()

      Ducttape::Cli::Root.write_database(database)

      puts server.export_yaml
    end

    desc "install <name>", "Install and configure server"
    def install(name)
    database = Ducttape::Cli::Root.load_database()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist"
        return
      end

      info = database['servers'][name]

      server = Ducttape::Models::Servers::Linux.retrieve(name, info)

      if (!Ducttape::Interfaces::Linux.check_openvpn_installed(server))
        if (Ducttape::Interfaces::Linux.install_openvpn(server))
          puts "OpenVPN installed!"
          server.installed = true
        else
          puts "OpenVPN installation failed!"
          server.installed = false
        end
      else
        puts "OpenVPN already installed!"
      end

      database['servers'][name] = server.export()

      Ducttape::Cli::Root.write_database(database)

      if(!server.configured)
        error = false
        if(File.file?(server.file_conf))
          Ducttape::Interfaces::Linux.upload_file(server, server.file_conf, "/etc/openvpn/server.conf")
        else
          puts "File missing 'file_conf' at #{server.file_conf}"
          error = true
        end
        if(File.file?(server.file_ca_crt))
          Ducttape::Interfaces::Linux.upload_file(server, server.file_ca_crt, "/etc/openvpn/ca.crt")
        else
          puts "File missing 'file_ca_crt' at #{server.file_ca_cert}"
          error = true
        end
        if(File.file?(server.file_pem))
          Ducttape::Interfaces::Linux.upload_file(server, server.file_pem, "/etc/openvpn/server.pem")
        else
          puts "File missing 'file_pem' at #{server.file_pem}"
          error = true
        end
        if(File.file?(server.file_crt))
          Ducttape::Interfaces::Linux.upload_file(server, server.file_crt, "/etc/openvpn/server.crt")
        else
          puts "File missing 'file_crt' at #{server.file_crt}"
          error = true
        end
        if(File.file?(server.file_key))
          Ducttape::Interfaces::Linux.upload_file(server, server.file_key, "/etc/openvpn/server.key")
        else
          puts "File missing 'file_key' at #{server.file_key}"
          error = true
        end
        if (!error)
          server.configured = true
          puts "OpenVPN configured!"
        else
          puts "OpenVPN configuration failed!"
        end
      else
        puts "OpenVPN already configured!"
      end

      puts "Restarting OpenVPN"
      Ducttape::Interfaces::Linux.start_openvpn_server(server)

      database['servers'][name] = server.export()

      Ducttape::Cli::Root.write_database(database)

    end
  end
end