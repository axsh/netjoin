# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

require_relative 'clients/linux'

module Netjoin::Cli

  class Clients < Thor

    desc "show","Show all clients"
    option :name, :type => :string
    def show()

      # Read database file
      database = Netjoin::Cli::Root.load_database()

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
      database = Netjoin::Cli::Root.load_database()

      # Check for existing client
      if (!database['clients'] or !database['clients'][name])
        puts "ERROR : client with name '#{name}' does not exist"
        return
      end

      # Update the database gile
      database['clients'].delete(name)
      Netjoin::Cli::Root.write_database(database)

      database['clients'].to_yaml()
    end

    desc "attach", "Attach to VPN Network"
    option :name, :type => :string
    def attach()
      # Read database file
      database = Netjoin::Cli::Root.load_database()

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
      database = Netjoin::Cli::Root.load_database()

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

    desc "refresh", "Update the remote IP in certificates by the server IP"
    def refresh()
      # Read database file
      database = Netjoin::Cli::Root.load_database()

      if (!database['clients'])
        return
      end

      puts " Refreshing remote IP addresses"

      database['clients'].each do |name, inst|
        # Create Client object to work with
        client = Netjoin::Models::Clients::Linux.retrieve(name, inst)
        # Check for key generation of file
        if(!Netjoin::Helpers::StringUtils.blank?(client.file_key))
          puts "  Updating #{client.name}"
          # Retrieve server
          serv = database['servers'][inst[:server]]
          server =  Netjoin::Models::Servers::Linux.retrieve(client.server, serv)

          text = File.read(client.file_key)
          new_contents = text.gsub(/remote .*/, "remote #{server.ip_address} #{server.port}")

          # To write changes to the file, use:
          File.open(client.file_key, "w") {|file| file.puts new_contents }
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
            client = Netjoin::Models::Clients::Linux.retrieve(name, inst)
            # Check server
            if(!database['servers'][client.server])
              puts "ERROR : Server does not exist!"
              return
            end
            server =  Netjoin::Models::Servers::Linux.retrieve(client.server, serv)

            client.status = :in_process

            # Check for OpenVPN installation on the client
            if(!client.error or client.error === :openvpn_not_installed)
              client.error = :openvpn_not_installed
              puts "  Checking OpenVPN installation!"
              if (Netjoin::Interfaces::Linux.check_openvpn_installed(client))
                client.error = nil
                puts "    OpenVPN already installed!"
              else
                puts "    Not installed, trying to install!"
                if (Netjoin::Interfaces::Linux.install_openvpn(client))
                  client.error = nil
                  puts "    Installed!"
                else
                  puts "ERROR:    Failed to install!"
                  client.status = :error
                end
              end
            end

            database['clients'][client.name] = client.export
            Netjoin::Cli::Root.write_database(database)

            if (client.generate_key == true)
              # Generate VPN certificate
              if(!client.error or client.error === :cert_generation_failed)
                puts "  Generating VPN Certificate"
                client.error = :cert_generation_failed
                ovpn = Netjoin::Interfaces::Linux.generate_certificate(server, client)
                if(ovpn)
                  puts "    Success"
                  client.error = nil
                else
                  puts "ERROR:    Failed generating certificate"
                  client.status = :error
                end
              else
                puts "  VPN Certificate already generated!"
              end
            end

            database['clients'][client.name] = client.export
            Netjoin::Cli::Root.write_database(database)

            if (server.mode === "static")
              if(!client.error or client.error === :static_ip_failed)
                puts "  Adding static IP address to ipp.txt of OpenVPN server!"
                client.error = :static_ip_failed
                Netjoin::Interfaces::Linux.set_vpn_ip_address(server, client)
                sleep(10)
                if (client.vpn_ip_address === Netjoin::Interfaces::Linux.get_vpn_ip_address(server, client.name))
                  puts "    Success!"
                end
                puts "  Restarting OpenVPN server for static IP allocation"
                if(Netjoin::Interfaces::Linux.restart_openvpn(server))
                  puts "    Success"
                  client.error = nil
                else
                  puts "ERROR:    Failed restarting OpenVPN!"
                  client.status = :error
                end
              end
            end

            database['clients'][client.name] = client.export
            Netjoin::Cli::Root.write_database(database)

            # Check certificate exists on path
            if(!client.error or client.error === :cert_file_missing)
              puts "  Check VPN Certificate"
              client.error = :cert_file_missing
              if(! client.file_key)
                client.file_key = "keys/#{client.name}.ovpn"
              end
              if(File.file?(client.file_key))
                puts "    Certificate file found!"
                client.error = nil
              else
                puts "ERROR:    Certificate file not found!"
                client.status = :error
              end
            end

            database['clients'][client.name] = client.export
            Netjoin::Cli::Root.write_database(database)

            # Install certificate
            if(!client.error or client.error === :cert_install_failed)
              puts "  Installing VPN Certificate"
              client.error = :cert_install_failed
              if(Netjoin::Interfaces::Linux.upload_file(client, client.file_key, "/tmp/#{client.name}.ovpn"))
                if(Netjoin::Interfaces::Linux.move_file(client, "/tmp/#{client.name}.ovpn", "/etc/openvpn/"))
                  puts "    Success"
                  client.error = nil
                else
                  puts "    Failed installing certificate!"
                  client.status = :error
                end
              else
                puts "ERROR:    Failed installing certificate!"
                client.status = :error
              end
            end

            database['clients'][client.name] = client.export
            Netjoin::Cli::Root.write_database(database)

            # Start OpenVPN
            if(!client.error or client.error === :openvpn_not_restarted)
              puts "  Restarting OpenVPN"
              client.error = :openvpn_not_restarted
              if(Netjoin::Interfaces::Linux.restart_openvpn(client))
                puts "    Success"
                client.error = nil
              else
                puts "ERROR:    Failed restarting OpenVPN!"
                client.status = :error
              end
            end

            database['clients'][client.name] = client.export
            Netjoin::Cli::Root.write_database(database)

            # Start OpenVPN using the certificate
            if(!client.error or client.error === :openvpn_not_started)
              puts "  Starting OpenVPN config"
              client.error = :openvpn_not_started
              if(Netjoin::Interfaces::Linux.start_openvpn_config(client))
                puts "    Success"
                client.error = nil
              else
                puts "ERROR:    Failed starting OpenVPN!"
                client.status = :error
              end
            end

            database['clients'][client.name] = client.export
            Netjoin::Cli::Root.write_database(database)

            if(!(client.status === :error))
              client.status = :attached
              puts "  Attached!"
              database['clients'][client.name] = client.export
              Netjoin::Cli::Root.write_database(database)
            else
              raise Exception.new("Something went wrong")
            end
          end

        end
      end
    }

    desc "linux SUBCOMMAND ...ARGS", "manage Linux clients"
    subcommand "linux", Netjoin::Cli::Client::Linux

  end

end