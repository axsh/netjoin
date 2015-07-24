# -*- coding: utf-8 -*-

require_relative 'base'
require_relative '../../models/servers/aws'
require_relative '../../interfaces/aws'

module Ducttape::Cli::Server

  class Aws < Base

    @type = 'aws'

    desc "add <name>","Add a new AWS server"
    option :key_pem, :type => :string
    option :region, :type => :string, :required => true
    option :zone, :type => :string, :required => true
    option :access_key_id, :type => :string, :required => true
    option :secret_key, :type => :string, :required => true
    option :ami, :type => :string, :required => true
    option :instance_type, :type => :string, :required => true
    option :key_pair, :type => :string, :required => true
    option :security_groups, :type => :array, :required => true
    def add(name)

      # Read database file
      database = Ducttape::Cli::Root.loadDatabase()

      # Check for existing server
      if (database['servers'] and database['servers'][name])
        puts "ERROR : server with name '#{name}' already exists"
        return
      end

      # Create Server object to work with
      server = Ducttape::Models::Servers::Aws.new(name,
        options[:region],
        options[:zone],
        options[:access_key_id],
        options[:secret_key],
        options[:ami],
        options[:instance_type],
        options[:key_pair],
        options[:security_groups]
      )

      # Update the database file
      if(!database['servers'])
        database['servers'] = {}
      end
      database['servers'][server.name()] = server.export()

      Ducttape::Cli::Root.writeDatabase(database)

      puts server.export_yaml
    end

    desc "update <name>", "Update an AWS server"
    option :key_pem, :type => :string
    option :region, :type => :string
    option :zone, :type => :string
    option :access_key_id, :type => :string
    option :secret_key, :type => :string
    option :ami, :type => :string
    option :instance_type, :type => :string
    option :key_pair, :type => :string
    option :security_groups, :type => :array
    def update(name)

      # Read database file
      database = Ducttape::Cli::Root.loadDatabase()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist"
        return
      end

      info = database['servers'][name]

      server = Ducttape::Models::Servers::Aws.retrieve(name, info)

      # Update the database file
      if (options[:key_pem])
        server.key_pem = options[:key_pem]
      end
      if (options[:region])
        server.region = options[:region]
      end
      if (options[:zone])
        server.zone = options[:zone]
      end
      if (options[:access_key_id])
        server.access_key = options[:access_key_id]
      end
      if (options[:secret_key])
        server.secret_key = options[:secret_key]
      end
      if (options[:ami])
        server.ami = options[:ami]
      end
      if (options[:instance_type])
        server.instance_type = options[:instance_type]
      end
      if (options[:key_pair])
        server.key_pair = options[:key_pair]
      end
      if (options[:security_groups])
        server.security_groups = options[:security_groups]
      end

      database['servers'][server.name()] = server.export()
      Ducttape::Cli::Root.writeDatabase(database)

      puts server.export_yaml
    end

    desc "create <name>", "Run server"
    def create(name)

      # Read database file
      database = Ducttape::Cli::Root.loadDatabase()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist"
        return
      end

      info = database['servers'][name]

      server = Ducttape::Models::Servers::Aws.retrieve(name, info)

      if(!server.instance_id)
        Ducttape::Interfaces::Aws.createInstance(server)
      else
        puts "Instance already created. skipping!"
      end

      database['servers'][server.name()] = server.export()
      Ducttape::Cli::Root.writeDatabase(database)

      puts "Initializing new instance, this will take a few minutes"

      puts "Check instance running, wait for 30 seconds and check again, abort by ctrl-c, rerun command to continue."

      status = Ducttape::Interfaces::Aws.getStatus(server)["instanceState"]
      while (!status or status["name"] != "running") do
        for i in 1..6
          sleep(5)
          puts "Waited #{i * 5} seconds"
        end
        puts "Checking status"
        status = Ducttape::Interfaces::Aws.getStatus(server)["instanceState"]
      end
      puts "Instance running, continuing"

      if (!server.ip_address or !server.public_dns_name)
        if (!Ducttape::Interfaces::Aws.getPublicIpAddress(server))
          puts "Public IP address or public DNS name not found!"
        end
      else
        puts "Public IP address already known!"
      end

      puts server.export_yaml

      database['servers'][server.name()] = server.export()
      Ducttape::Cli::Root.writeDatabase(database)
    end

    desc "install <name>", "Install and configure server"
    def install(name)

      # Read database file
      database = Ducttape::Cli::Root.loadDatabase()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist"
        return
      end

      info = database['servers'][name]

      server = Ducttape::Models::Servers::Aws.retrieve(name, info)

      status = Ducttape::Interfaces::Aws.getStatus(server)["instanceStatus"]["status"]

      if(status != "ok")
        puts "Instance not ready, please try again later"
        return
      end

      if (!server.installed or !Ducttape::Interfaces::Aws.checkOpenVpnInstalled(server))
        if (Ducttape::Interfaces::Aws.installOpenVpn(server))
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

      Ducttape::Cli::Root.writeDatabase(database)

      if(!server.installed)
        puts "Server not installed, aborting!"
        return
      end

      if(!server.configured)
        error = false
        if(File.file?(server.file_conf))
          Ducttape::Interfaces::Aws.uploadFile(server, server.file_conf, "server.conf")
          Ducttape::Interfaces::Aws.moveFile(server, "server.conf", "/etc/openvpn/server.conf")
        else
          puts "File missing 'file_conf' at #{server.file_conf}"
          error = true
        end
        if(File.file?(server.file_ca_crt))
          Ducttape::Interfaces::Aws.uploadFile(server, server.file_ca_crt, "ca.crt")
          Ducttape::Interfaces::Aws.moveFile(server, "ca.crt", "/etc/openvpn/ca.crt")
        else
          puts "File missing 'file_ca_crt' at #{server.file_ca_cert}"
          error = true
        end
        if(File.file?(server.file_pem))
          Ducttape::Interfaces::Aws.uploadFile(server, server.file_pem, "server.pem")
          Ducttape::Interfaces::Aws.moveFile(server, "server.pem", "/etc/openvpn/server.pem")
        else
          puts "File missing 'file_pem' at #{server.file_pem}"
          error = true
        end
        if(File.file?(server.file_crt))
          Ducttape::Interfaces::Aws.uploadFile(server, server.file_crt, "server.crt")
          Ducttape::Interfaces::Aws.moveFile(server, "server.crt", "/etc/openvpn/server.crt")
        else
          puts "File missing 'file_crt' at #{server.file_crt}"
          error = true
        end
        if(File.file?(server.file_key))
          Ducttape::Interfaces::Aws.uploadFile(server, server.file_key, "server.key")
          Ducttape::Interfaces::Aws.moveFile(server, "server.key", "/etc/openvpn/server.key")
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
      Ducttape::Interfaces::Aws.startOpenVpnServer(server)

      database['servers'][name] = server.export()

      Ducttape::Cli::Root.writeDatabase(database)

    end

    desc "status <name>", "Status server"
    def status(name)
      # Read database file
      database = Ducttape::Cli::Root.loadDatabase()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist"
        return
      end

      info = database['servers'][name]

      server = Ducttape::Models::Servers::Aws.retrieve(name, info)

      status = Ducttape::Interfaces::Aws.getStatus(server)
      if(!status)
        puts "Unable to get status!"
        return
      end
      puts status.to_yaml()

    end

    desc "describe <name>", "describe"
    def describe(name)
      # Read database file
      database = Ducttape::Cli::Root.loadDatabase()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist"
        return
      end

      info = database['servers'][name]

      server = Ducttape::Models::Servers::Aws.retrieve(name, info)

      Ducttape::Interfaces::Aws.describe(server)

    end
  end
end