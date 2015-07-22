# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

require_relative 'clients/linux'

module DucttapeCLI

  class Clients < Thor

    desc "show","Show all clients"
    option :name, :type => :string
    def show()

      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()

      if (!database['clients'])
        return
      end
      
      # If specific client is asked, show that client only, if not, show all
      if (options[:name])
        if (!database['clients'][options[:name]])
          puts "ERROR : client with name '#{options[:name]}' does not exist" 
          return
        end
        puts database['clients'][options[:name]].to_yaml()
      else
        puts database['clients'].to_yaml()
      end

    end

    desc "delete <name>", "Delete an client"
    def delete(name)

      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()

      # Check for existing client
      if (!database['clients'] or !database['clients'][name])
        puts "ERROR : client with name '#{name}' does not exist" 
        return
      end

      # Update the database gile
      database['clients'].delete(name)
      DucttapeCLI::CLI.writeDatabase(database)
      
      database['clients'].to_yaml()
    end
    
    desc "attach", "Attach to VPN Network"
    option :name, :type => :string
    def attach()
      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()
      
      if (!database['clients'])
        return
      end
      
      if (options[:name])
        if (!database['clients'][options[:name]])
          puts "ERROR : client with name '#{options[:name]}' does not exist" 
          return
        else
          self.attach_client(database, options[:name], database['clients'][options[:name]])
        end
      else
        database['clients'].each do |name, inst|
          self.attach_client(database, name, inst);
        end        
      end
      
    end
    
    desc "status", "Status of the clients"
    option :name, :type => :string
    def status()
      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()
           
      if (!database['clients'])
        return
      end
      
      # Check for existing client
      if (options[:name])
        if (!database['clients'][options[:name]])
          puts "ERROR : client with name '#{options[:name]}' does not exist" 
          return
        else
          puts database['clients'][options[:name]][:status]
        end
      else
        database['clients'].each do |name, inst|
          puts "\"#{name}\" : #{inst[:status]}"
        end
      end
    end
    
    no_commands {
     
      def attach_client(database, name, inst)
        puts "Attaching \"#{name}\""
        serv = database['servers'][inst[:server]]
        status = inst[:status]
        if(status == :attached)
          puts "  #{name} already attached, skipping"
        else
          if (:linux === inst[:type])
            
            # Create Client object to work with
            client = Ducttape::Clients::Linux.retrieve(name, inst)
            server =  Ducttape::Servers::Linux.retrieve(client.server, serv)
                
            client.status = :in_process

            # Check for OpenVPN installation on the client
            if(!client.error or client.error === :openvpn_not_installed)
              client.error = :openvpn_not_installed
              puts "  Checking OpenVPN installation"
              if (Ducttape::Interfaces::Linux.checkOpenVpnInstalled(client))            
                client.error = nil
                puts "    Installed"
              else
                puts "    Not installed, trying to install!"
                if (Ducttape::Interfaces::Linux.installOpenVpn(client))
                  client.error = nil
                  puts "    Installed"
                else
                  puts "    Failed to install!"
                  client.status = :error
                end              
              end
            end
              
            if (client.generate_key == 'true')
              # Generate VPN certificate 
              if(!client.error or client.error === :cert_generation_failed)
                puts "  Generating VPN Certificate"
                client.error = :cert_generation_failed
                ovpn = Ducttape::Interfaces::Linux.generateCertificate(server, client)
                if(ovpn)
                  puts "    Success"
                  client.error = nil             
                else
                  puts "    Failed generating certificate"
                  client.status = :error
                end
              end
            end
            if (server.mode === :static)
              Ducttape::Interfaces::Linux.setVpnIpAddress(server, client)
            end

            # Check certificate exists on path
            if(!client.error or client.error === :cert_file_missing)
              puts "  Check VPN Certificate"
              client.error = :cert_file_missing
              if(File.file?("keys/#{client.name}.ovpn"))
                puts "    Certificate file found"
                client.error = nil
              else
                puts "    Certificate file not found!"
                client.status = :error
              end
            end
            
            # Install certificate
            if(!client.error or client.error === :cert_install_failed)
              puts "  Installing VPN Certificate"
              client.error = :cert_install_failed
              if(Ducttape::Interfaces::Linux.installCertificate(client))
                puts "    Success"
                client.error = nil
              else
                puts "    Failed installing certificate!"
                client.status = :error
              end
            end

            # Start OpenVPN using the certificate          
            if(!client.error or client.error === :openvpn_not_started)
              puts "  Starting OpenVPN"
              client.error = :openvpn_not_started
              if(Ducttape::Interfaces::Linux.startOpenVpnClient(client))
                puts "    Success"
                client.error = nil
              else
                puts "    Failed starting OpenVPN!"
                client.status = :error
              end
            end
  
            if(!(client.status === :error))
              client.status = :attached
              puts "  Attached!"
            end
          end
          database['clients'][client.name] = client.export
        end
        DucttapeCLI::CLI.writeDatabase(database)
      end 
    }

    desc "linux SUBCOMMAND ...ARGS", "manage Linux clients"
    subcommand "linux", DucttapeCLI::Client::Linux

  end   

end