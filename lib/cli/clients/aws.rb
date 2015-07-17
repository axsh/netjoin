# -*- coding: utf-8 -*-

require_relative 'base'
require_relative '../../clients/aws'
require_relative '../../interfaces/aws'

module DucttapeCLI::Client
    
  class Aws < Base
    
    @type = 'aws'
    
    desc "add <name>","Add a new AWS client"
    option :region, :type => :string, :required => true
    option :vpc, :type => :string, :required => true
    option :ip_address, :type => :string, :required => true
    option :access_key, :type => :string, :required => true
    option :secret_key, :type => :string, :required => true
    def add(name)

      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()

      # Check for existing client
      if (database['clients'] and database['clients'][name])
        puts "ERROR : client with name '#{name}' already exists" 
        return
      end      

      # Create Client object to work with
      client = Ducttape::Clients::Aws.new(name, options[:region], options[:vpc], options[:ip_address], options[:access_key], options[:secret_key])

      puts "Creating VPN Gateway"
      Ducttape::Interfaces::Aws.createVpnGateway(client)
      puts "Attaching VPC to VPN Gateway"
      Ducttape::Interfaces::Aws.attachVpc(client)
      puts "Creating Customer Gateway"
      # TODO support other than linux servers 
      server_ip = database['servers'][client.server][:data][:ip_address]
      Ducttape::Interfaces::Aws.createCustomerGateway(client, server_ip)

      # Update the database file
      if(!database['clients'])
        database['clients'] = {}
      end  
      database['clients'][client.name()] = client.export()     

      DucttapeCLI::CLI.writeDatabase(database)
    end
    
    desc "update <name>", "Update an AWS client"
    option :region, :type => :string
    option :vpc, :type => :string
    option :access_key, :type => :string
    option :secret_key, :type => :string
    def update(name)

      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()

      # Check for existing client
      if (!database['clients'] or !database['clients'][name])
        puts "ERROR : client with name '#{name}' does not exist" 
        return
      end

      data = database['clients'][name][:data]

      client = Ducttape::Clients::Aws.new(name, data[:access_key], data[:secret_key])

      # Update the database file
      if (options[:region])
        client.secret_key = options[:region]
      end
      if (options[:vpc])
        client.vpc = options[:vpc]
      end
      if (options[:access_key])
        client.access_key = options[:access_key] 
      end
      if (options[:secret_key])
        client.secret_key = options[:secret_key]
      end
      
      database['clients'][client.name()] = client.export()
      DucttapeCLI::CLI.writeDatabase(database)
    end

  end

end