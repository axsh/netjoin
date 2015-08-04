# -*- coding: utf-8 -*-

require 'csv'
require 'net/scp'
require 'net/ssh'

require_relative 'base'
require_relative '../models/servers/base'

module Ducttape::Interfaces

  class Linux < Base

    def self.upload_file(client, source, destination)
      Net::SCP.start(client.ip_address, client.username, Base.auth_param(client)) do |scp|
        scp.upload!(source, destination)
        return true
      end
      return false
    end

    def self.move_file(client, source, destination)
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        ssh.open_channel do |channel|
          channel.request_pty do |ch, success|
            if !success
              puts "Could not obtain pty"
            end
          end

          channel.exec("sudo mv #{source} #{destination}") do |ch, success|
            abort "Could not execute commands!" unless success
            channel.on_data do |ch, data|
              puts ch.exec("sudo ls /etc/openvpn")
            end
            channel.on_extended_data do |ch, type, data|
              puts "stderr: #{data}"
            end
          end
        end
      end
    end

    def self.check_openvpn_installed(client)
      installed = false
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        ssh.open_channel do |channel|
          channel.request_pty do |ch, success|
            if !success
              puts "Could not obtain pty"
            end
          end

          channel.exec('sudo rpm -qa | grep openvpn') do |ch, success|
            abort "Could not execute commands!" unless success
            channel.on_data do |ch, data|
              if (data.include?("openvpn"))
                 installed = true
              end
              channel.on_extended_data do |ch, type, data|
                puts "stderr: #{data}"
              end
            end
          end
        end
      end
      return installed
    end

    def self.install_openvpn(client)
      installed = false
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        ssh.open_channel do |channel|
          channel.request_pty do |ch, success|
            if !success
              puts "Could not obtain pty"
            end
          end

          channel.exec('sudo yum install -y openvpn') do |ch, success|
            abort "Could not execute commands!" unless success
            channel.on_data do |ch, data|
              if (data.include?("Complete!") or data.include?("Nothing to do"))
                installed = true
              end
            end
            channel.on_extended_data do |ch, type, data|
              puts "stderr: #{data}"
            end
          end
        end
      end
      return installed
    end

    def self.restart_openvpn(client)
      restarted = false
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        ssh.open_channel do |channel|
          channel.request_pty do |ch, success|
            if !success
              puts "Could not obtain pty"
            end
          end

          channel.exec("sudo service openvpn restart") do |ch, success|
            abort "Could not execute commands!" unless success
            channel.on_data do |ch, data|
              restarted = true
            end
            channel.on_extended_data do |ch, type, data|
              puts "stderr: #{data}"
            end
          end
        end
      end
      return restarted
    end

    def self.start_openvpn_config(client)
      filename = client.name
      if(client.respond_to?(:port))
        puts "    Starting as a server"
        filename += ".conf"
      else
        puts "    Starting as a client"
        filename += ".ovpn"
      end
      config = false
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        ssh.open_channel do |channel|
          channel.request_pty do |ch, success|
            if !success
              puts "Could not obtain pty"
            end
          end
          channel.exec("sudo openvpn --config /etc/openvpn/#{filename} --daemon")  do |ch, success|
            abort "Could not execute commands!" unless success
            config = true
            channel.on_extended_data do |ch, type, data|
              puts "stderr: #{data}"
            end
          end
        end
      end
      return config
    end

    def self.generate_certificate(server, client)
      Net::SSH.start(server.ip_address, server.username, Base.auth_param(client)) do |ssh|
        ls = ssh.exec!("ls /etc/openvpn/easy-rsa/keys/#{client.name}.crt")
        if(ls == "/etc/openvpn/easy-rsa/keys/#{client.name}.crt\n")
          puts "    Already generated"
        else
          build = ssh.exec!("cd /etc/openvpn/easy-rsa/ && source ./vars && ./build-key #{client.name}")
        end
        ca = ssh.exec!("cat /etc/openvpn/easy-rsa/keys/ca.crt")
        cert = ssh.exec!("cat /etc/openvpn/easy-rsa/keys/#{client.name}.crt")
        key = ssh.exec!("cat /etc/openvpn/easy-rsa/keys/#{client.name}.key")
        if(server.port)
          port = server.port
        else
          port = 1194
        end
        file = "client
dev tun
proto udp
remote #{server.ip_address} #{port}
resolv-retry infinite
nobind
persist-key
persist-tun
comp-lzo
verb 3
<ca>
#{ca}
</ca>
<cert>
#{cert}
</cert>
<key>
#{key}
</key>
"
        if (!ca or !cert or !key)
          puts "  ERROR"
          puts build
          return false
        end
        Ducttape::Cli::Root.write_file("keys/#{client.name}.ovpn",file)
        return file
      end
      return false
    end

    def self.install_certificate(client, key)
      return Linux.upload_file(client, key, "/etc/openvpn/#{client.name}.ovpn")
    end

    def self.set_vpn_ip_address(server, client)
      done = false
      if (!Linux.get_vpn_ip_address(server, client.name))
        Net::SSH.start(server.ip_address, server.username, Base.auth_param(server)) do |ssh|
          ssh.open_channel do |channel|
            channel.request_pty do |ch, success|
              if !success
                puts "Could not obtain pty"
              end
            end
            channel.exec("sudo echo #{client.name},#{client.vpn_ip_address} >> /etc/openvpn/ipp.txt && cat /etc/openvpn/ipp.txt") do |ch, success|
              abort "Could not execute commands!" unless success
            end
            channel.on_extended_data do |ch, type, data|
              puts "stderr: #{data}"
            end
          end
        end
      end
      return done
    end

    def self.get_vpn_ip_address(server, client_name)
      ip = nil
      Net::SSH.start(server.ip_address, server.username, Base.auth_param(server)) do |ssh|
        ssh.open_channel do |channel|
          channel.request_pty do |ch, success|
            if !success
              puts "Could not obtain pty"
            end
          end
          channel.exec("sudo cat /etc/openvpn/ipp.txt") do |ch, success|
            abort "Could not execute commands!" unless success
            channel.on_data do |ch, data|
              if (data)
                csv = CSV.new(data)
                csv.each { |row|
                  name, ip_address = row
                  if (name == client_name)
                    ip = ip_address
                  end
                }
              end
            end
            channel.on_extended_data do |ch, type, data|
              puts "stderr: #{data}"
            end
          end
        end
      end
      return ip
    end

  end

end