# -*- coding: utf-8 -*-

require_relative 'base'
require_relative '../../models/servers/aws'
require_relative '../../interfaces/aws'

module Netjoin::Cli::Server

  class Aws < Base

    @type = 'aws'

    desc "add <name>","Add a new AWS server"
    option :access_key_id, :type => :string, :required => true
    option :ami, :type => :string, :required => true
    option :configured, :type => :string
    option :file_ca_crt, :type => :string
    option :file_conf, :type => :string
    option :file_crt, :type => :string
    option :file_key, :type => :string
    option :file_pem, :type => :string
    option :installed, :type => :string
    option :instance_type, :type => :string, :required => true
    option :key_pair, :type => :string, :required => true
    option :key_pem, :type => :string
    option :password, :type => :string
    option :port, :type => :string, :required => true
    option :region, :type => :string, :required => true
    option :secret_key, :type => :string, :required => true
    option :security_groups, :type => :array, :required => true
    option :username, :type => :string
    option :zone, :type => :string, :required => true
    def add(name)
      # Read database file
      database = Netjoin::Cli::Root.load_database()

      # Check for existing server
      if (database['servers'] and database['servers'][name])
        puts "ERROR : server with name '#{name}' already exists"
        return
      end

      # Check for a way to log in
      if(Netjoin::Helpers::StringUtils.blank?(options[:password]) and Netjoin::Helpers::StringUtils.blank?(options[:key_pem]))
        puts "ERROR : Missing a password or pem key file to ssh/scp"
        return
      end

      # Create Server object to work with
      server = Netjoin::Models::Servers::Aws.new(name,
        options[:region],
        options[:zone],
        options[:access_key_id],
        options[:secret_key],
        options[:ami],
        options[:instance_type],
        options[:key_pair],
        options[:security_groups]
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
      server.password = options[:username] if options[:username]

      # Update the database file
      if(!database['servers'])
        database['servers'] = {}
      end
      database['servers'][server.name()] = server.export()

      Netjoin::Cli::Root.write_database(database)

      puts server.export_yaml
    end

    desc "update <name>", "Update an AWS server"
    option :access_key_id, :type => :string
    option :ami, :type => :string
    option :configured, :type => :string
    option :file_ca_crt, :type => :string
    option :file_conf, :type => :string
    option :file_crt, :type => :string
    option :file_key, :type => :string
    option :file_pem, :type => :string
    option :installed, :type => :string
    option :instance_type, :type => :string
    option :key_pair, :type => :string
    option :key_pem, :type => :string
    option :password, :type => :string
    option :port, :type => :string
    option :region, :type => :string
    option :secret_key, :type => :string
    option :security_groups, :type => :array
    option :username, type => :string
    option :zone, :type => :string
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
      server = Netjoin::Models::Servers::Aws.retrieve(name, info)

      # Update the database file
      server.access_key_id = options[:access_key_id] if options[:access_key_id]
      server.ami = options[:ami] if options[:ami]
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
      server.instance_type = options[:instance_type] if options[:instance_type]
      server.key_pair = options[:key_pair] if options[:key_pair]
      server.key_pem = options[:key_pem] if options[:key_pem]
      server.password = options[:password] if options[:password]
      server.port = options[:port] if options[:port]
      server.region = options[:region] if options[:region]
      server.secret_key = options[:secret_key] if options[:secret_key]
      server.security_groups = options[:security_groups] if options[:security_groups]
      server.username = options[:username] if options[:username]
      server.zone = options[:zone] if options[:zone]

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

    desc "create <name>", "Run server"
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
      server = Netjoin::Models::Servers::Aws.retrieve(name, info)

      # Check if server has already been created on AWS
      if(!server.instance_id)
        puts "Initializing new instance, this will take a few minutes"
        Netjoin::Interfaces::Aws.create_instance(server)
      else
        puts "Instance already created. skipping!"
      end

      # Save instance creation information
      database['servers'][server.name()] = server.export()
      Netjoin::Cli::Root.write_database(database)

      puts "Checking for running instance,  abort by ctrl-c, rerun command to continue."

      status = Netjoin::Interfaces::Aws.status(server)
      while(status == nil) do
        puts "No instance found, checking every 5 seconds!"
        sleep(5)
        status = Netjoin::Interfaces::Aws.status(server)
      end
      state = status["instanceState"]
      while (!state or state["name"] != "running") do
        puts "Instance not running or busy initializing, checking again in 30 seconds!"
        for i in 1..6
          sleep(5)
          puts "Waited #{i * 5} seconds"
        end
        puts "Checking status"
        state = Netjoin::Interfaces::Aws.status(server)["instanceState"]
      end
      puts "Instance running, continuing"

      # Retrieve public IP Address
      if (!server.ip_address or !server.public_dns_name)
        if (!Netjoin::Interfaces::Aws.public_ip_address(server))
          puts "Public IP address or public DNS name not found!"
        end
      else
        puts "Public IP address already known!"
      end

      # Write database file
      database['servers'][server.name()] = server.export()
      Netjoin::Cli::Root.write_database(database)

      puts server.export_yaml
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
      server = Netjoin::Models::Servers::Aws.retrieve(name, info)

      # Check if instance is ready
      puts "Checking instance status"
      status = Netjoin::Interfaces::Aws.status(server)["instanceStatus"]["status"]
      if(status != "ok")
        puts "Instance not ready, please try again later"
        return
      end

      # Check OpenVPN installation, install if missing
      puts "Checking OpenVPN installation"
      if (!server.installed or !Netjoin::Interfaces::Aws.check_openvpn_installed(server))
        puts "  Not installed, installing now"
        if (Netjoin::Interfaces::Aws.install_openvpn(server))
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
        if(Netjoin::Interfaces::Aws.upload_openvpn_config(server))
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
      if(Netjoin::Interfaces::Aws.restart_openvpn(server))
        puts "  OpenVPN restart : success!"
      else
        puts "  OpenVPN restart : failed!"
      end

      puts server.export_yaml
    end

    desc "status <name>", "Status server"
    def status(name)
      # Read database file
      database = Netjoin::Cli::Root.load_database()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist"
        return
      end

      info = database['servers'][name]
      server = Netjoin::Models::Servers::Aws.retrieve(name, info)
      status = Netjoin::Interfaces::Aws.status(server)

      if(!status)
        puts "Unable to get status!"
        return
      end

      puts status.to_yaml()
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

      info = database['servers'][name]
      server = Netjoin::Models::Servers::Aws.retrieve(name, info)
      response = Netjoin::Interfaces::Aws.describe(server)

      puts response.to_yaml()
    end
  end
end