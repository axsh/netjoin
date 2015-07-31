# -*- coding: utf-8 -*-

require 'csv'
require 'net/scp'
require 'net/ssh'

require_relative 'base'

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
      config = false
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        ssh.open_channel do |channel|
          channel.request_pty do |ch, success|
            if !success
              puts "Could not obtain pty"
            end
          end
          channel.exec("sudo openvpn --config /etc/openvpn/#{client.name}.ovpn --daemon")  do |ch, success|
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
        file = "client
dev tun
proto udp
remote #{server.ip_address} 1194
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
      if (!Ducttape::Interfaces::Linux.get_vpn_ip_address(server, client))
        Net::SSH.start(server.ip_address, server.username, Base.auth_param(client)) do |ssh|
          ip = Linux.get_vpn_ip_address(server,client)
          if !ip
            ssh.exec!("sudo echo #{client.name},#{client.vpn_ip_address} >> /etc/openvpn/ipp.txt")
          end
        end
      end
    end

    def self.get_vpn_ip_address(server, client)
      Net::SSH.start(server.ip_address, server.username, Base.auth_param(client)) do |ssh|
        ipp = ssh.exec!("sudo cat /etc/openvpn/ipp.txt")
        if (ipp)
          csv = CSV.new(ipp)
          csv.each { |row|
            name, ip_address = row
            if (name == client.name())
              return ip_address
            end
          }
        end
      end
      return nil
    end

  end

end