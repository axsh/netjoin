# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

require_relative 'instances/aws'
require_relative 'instances/linux'

module DucttapeCLI

  class Instances < Thor

    desc "show","Show all instances"
    options :name => :string
    def show()

      # Read config file
      config = DucttapeCLI.loadConfig()

      if (!config['instances'])
        return
      end
      # If specific instance is asked, show that instance only, if not, show all
      if (options[:name])
        puts config['instances'][options[:name]].inspect
      else
        puts config['instances'].inspect
      end

    end

    desc "delete <name>", "Delete an instance"
    def delete(name)

      # Read config file
      config = DucttapeCLI.loadConfig()

      # Check for existing instance
      if (!config['instances'] or !config[name])
        puts "ERROR : instance with name '#{name}' doest not exist" 
        return
      end

      # Update the config gile
      config['instances'].delete(name)
      DucttapeCLI.writeConfig(config)
    end
    
    desc "attach", "Attach to VPN Network"
    def attach()
      # Read config file
      config = DucttapeCLI.loadConfig()
      
      if (!config['instances'])
        return
      end
      
      config['instances'].each do |name, instance|
        if (:linux === instance[:type])
          puts "it's a linux instance"
          # Create Instance object to work with
          instance = Ducttape::Instances::Linux.new(name, options[:server], options[:ip_address], options[:username], options[:password])
       
          # Check for OpenVPN installation on the instance
          if (!Ducttape::Interfaces::Linux.checkOpenVpnInstalled(instance))
            puts "OpenVPN not installed, aborting!"
            return
          end
          
          # TODO
          # Create OpenVPN Certificate on server
          # Put certificate on the instance
          # Start OpenVPN with the new certificate
       
        end
      end
      
    end
    
    # TODO finish implementing AWS Support
    #desc "aws SUBCOMMAND ...ARGS", "manage AWS instances"
    #subcommand "aws", DucttapeCLI::Instance::Aws
    desc "linux SUBCOMMAND ...ARGS", "manage Linux instances"
    subcommand "linux", DucttapeCLI::Instance::Linux

  end   

end