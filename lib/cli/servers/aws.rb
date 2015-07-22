# -*- coding: utf-8 -*-

require_relative 'base'
require_relative '../../servers/aws'
require_relative '../../interfaces/aws'

module DucttapeCLI::Server
    
  class Aws < Base
    
    @type = 'aws'
    
    desc "add <name>","Add a new AWS server"
    option :region, :type => :string, :required => true
    option :zone, :type => :string, :required => true
    option :access_key_id, :type => :string, :required => true
    option :secret_key, :type => :string, :required => true
    option :ami, :type => :string, :required => true
    option :instance_type, :type => :string, :required => true
    def add(name)

      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()

      # Check for existing server
      if (database['servers'] and database['servers'][name])
        puts "ERROR : server with name '#{name}' already exists" 
        return
      end      

      # Create Server object to work with
      server = Ducttape::Servers::Aws.new(name, options[:region], options[:zone], options[:access_key_id], options[:secret_key])
      server.ami = options[:ami]
      server.instance_type = options[:instance_type]

      # Update the database file
      if(!database['servers'])
        database['servers'] = {}
      end  
      database['servers'][server.name()] = server.export()     

      DucttapeCLI::CLI.writeDatabase(database)
      
      puts server.export_yaml
    end
    
    desc "update <name>", "Update an AWS server"
    option :region, :type => :string
    option :zone, :type => :string
    option :access_key_id, :type => :string
    option :secret_key, :type => :string
    option :ami, :type => :string
    option :instance_type, :type => :string
    def update(name)

      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist" 
        return
      end

      info = database['servers'][name]

      server = Ducttape::Servers::Aws.retrieve(name, info)

      # Update the database file
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
            
      database['servers'][server.name()] = server.export()
      DucttapeCLI::CLI.writeDatabase(database)
      
      puts server.export_yaml
    end
    
    desc "install <name>", "Install server"
    def install(name)
      
      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()

      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist" 
        return
      end

      info = database['servers'][name]

      server = Ducttape::Servers::Aws.retrieve(name, info)
      
      if(!server.instance_id)  
        Ducttape::Interfaces::Aws.createInstance(server)
      else
        puts "Instance already created. skipping!"
      end
      
      if (!server.ip_address)
        ip_address = Ducttape::Interfaces::Aws.getPublicIpAddress(server)
        if (!ip_address)
          puts "Public IP address not found!"
        else
          server.ip_address = ip_address
        end
      else
        puts "Public IP address already known!"
      end
      
      puts server.export_yaml
      
      database['servers'][server.name()] = server.export()
      DucttapeCLI::CLI.writeDatabase(database)

    end

  end

end