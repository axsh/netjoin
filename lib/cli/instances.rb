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
      
      config['instances'].each do |name, inst|
        if (:linux === inst[:type])
          status = inst[:status]
          error = inst[:error]
          if(status == :attached)
            puts "#{name} already attached, skipping"
            return
          end
          
          # Create Instance object to work with
          instance = Ducttape::Instances::Linux.new(name, inst[:server], inst[:data][:ip_address], inst[:data][:username], inst[:data][:password])
          config = DucttapeCLI::loadConfig()
          server =  Ducttape::Servers::Linux.new(instance.server, config['servers'][:ip_address], config['servers'][:username], config['servers'][:password])
              
          instance.status = :in_process
         
          # Check for OpenVPN installation on the instance
          if(!error or error === :openvnet_not_installed)
            instance.error = :openvnet_not_installed
            if (Ducttape::Interfaces::Linux.checkOpenVpnInstalled(instance))            
              instance.error = nil
            else
              puts "OpenVPN not installed, aborting!"
              instance.status = :error
              return
            end
          end
          
          # Generate VPN certificate
          if(!error or error === :cert_generation_failed)
            instance.error = :cert_generation_failed
            ovpn = Ducttape::Interfaces::Linux.generateCertificate(server, instance)
            if(ovpn)
              instance.error = nil
            else
              puts "Failed generating certificate"
              instance.status = :error
              return
            end
          end
          
          # Install certificate
          if(!error or error === :cert_generation_failed)
            instance.error = :cert_install_failed
            if(Ducttape::Interfaces::Linux.installCertificate(instance, ovpn))
              instance.error = nil
            else
              puts "Failed installing certificate!"
              instance.status = :error
              return
            end
          end
          
          # Start OpenVPN using the certificate
          if(!error or error === :cert_generation_failed)
            instance.error = :openvpn_not_started
            if(Ducttape::Interfaces::Linux.startOpenVPN(instance))
              instance.error = nil
            else
              puts "Failed starting OpenVPN!"
              instance.status = :error
              return
            end
          end
          
          instance.status = :attached
        end
        config['instances'][instance.name] = instance.export      
      end
      DucttapeCLI.writeConfig(config)
      
    end
    
    # TODO finish implementing AWS Support
    #desc "aws SUBCOMMAND ...ARGS", "manage AWS instances"
    #subcommand "aws", DucttapeCLI::Instance::Aws
    desc "linux SUBCOMMAND ...ARGS", "manage Linux instances"
    subcommand "linux", DucttapeCLI::Instance::Linux

  end   

end