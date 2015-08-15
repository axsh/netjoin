# -*- coding: utf-8 -*-

require 'csv'
require 'net/scp'
require 'net/ssh'

require_relative 'base'
require_relative '../models/servers/base'

module Netjoin::Interfaces

  class Linux < Base

    def self.upload_file(client, source, destination)
      Net::SCP.start(client.ip_address, client.username, Base.auth_param(client)) do |scp|
        scp.upload!(source, destination)
        return true
      end
      return false
    end

    def self.mkdir(client, dir_name)
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        ssh.open_channel do |channel|
          channel.request_pty do |ch, success|
            if !success
              puts "Could not obtain pty"
            end
          end

          channel.exec("mkdir #{dir_name}") do |ch, success|
            abort "Could not execute commands!" unless success
            channel.on_data do |ch, data|
              puts ch.exec("ls #{dir_name}")
            end
            channel.on_extended_data do |ch, type, data|
              puts "stderr: #{data}"
            end
          end
        end
      end
    end

    def self.move_file(client, source, destination)
      moved = false
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        ssh.open_channel do |channel|
          channel.request_pty do |ch, success|
            if !success
              puts "Could not obtain pty"
            end
          end

          channel.exec("sudo mv #{source} #{destination}") do |ch, success|
            abort "Could not execute commands!" unless success
            moved = true
            channel.on_extended_data do |ch, type, data|
              puts "stderr: #{data}"
            end
          end
        end
      end
      return moved
    end

    def self.retrieve_hash(client, file_path)
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        ssh.open_channel do |channel|
          channel.request_pty do |ch, success|
            if !success
              puts "Could not obtain pty"
            end
          end

          channel.exec("sudo cat #{file_path} | sed -n \"/-----BEGIN.*-----/,/-----END.*-----/p\"") do |ch, success|
            abort "Could not execute commands!" unless success
            channel.on_data do |ch, data|
              puts "### Reading #{file_path}"
              puts "#{data}"
              return data
            end
            channel.on_extended_data do |ch, type, data|
              puts "stderr: #{data}"
            end
          end
        end
      end
      return nil
    end

    def self.check_epel_installed(client)
      installed = false
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        ssh.open_channel do |channel|
          channel.request_pty do |ch, success|
            if !success
              puts "Could not obtain pty"
            end
          end

          channel.exec('sudo rpm -qa | grep epel-release') do |ch, success|
            abort "Could not execute commands!" unless success
            channel.on_data do |ch, data|
              if (data.include?("epel-release"))
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

    def self.install_epel(client)
      installed = false
      Net::SSH.start(client.ip_address, client.username, Base.auth_param(client)) do |ssh|
        ssh.open_channel do |channel|
          channel.request_pty do |ch, success|
            if !success
              puts "Could not obtain pty"
            end
          end

          channel.exec('sudo yum install -y epel-release') do |ch, success|
            abort "Could not execute commands!" unless success
            channel.on_data do |ch, data|
              if (!data.include?("Error") and (data.include?("Complete!") or data.include?("Nothing to do")))
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
              if (!data.include?("Error") and (data.include?("Complete!") or data.include?("Nothing to do")))
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
#      Net::SSH.start(server.ip_address, server.username, Base.auth_param(server)) do |ssh|
#        ssh.open_channel do |channel|
#          channel.request_pty do |ch, success|
#            if !success
#              puts "Could not obtain pty"
#            end
#          end
#          channel.exec("sudo bash <<< 'cd /etc/openvpn/easy-rsa && . vars && . build-key #{client.name}'")  do |ch, success|
#            abort "Could not execute commands!" unless success
##            channel.on_data do |ch, data|
##              puts data
##            end
#            channel.on_extended_data do |ch, type, data|
#              puts "stderr: #{data}"
#            end
#          end
#        end
#      end
      ca = Linux.retrieve_hash(server, "/etc/openvpn/easy-rsa/keys/ca.crt")
      cert = Linux.retrieve_hash(server, "/etc/openvpn/easy-rsa/keys/#{client.name}.crt")
      key = Linux.retrieve_hash(server, "/etc/openvpn/easy-rsa/keys/#{client.name}.key")
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
        puts "  ERROR, missing one of the files"
        puts "### FILE"
        puts file
        return false
      end
      Netjoin::Cli::Root.write_file("keys/#{client.name}.ovpn",file)
      return file
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

    def self.upload_openvpn_config(server, database)
      required_file_exist = false

      if !server.file_conf.nil? && File.exist?(server.file_conf)
        Netjoin::Interfaces::Linux.upload_file(server, server.file_conf, "/etc/openvpn/")
      else
        if server.mode == "site-to-site"
          path = generate_site_to_site_conf_file(server, database)
          Netjoin::Interfaces::Linux.upload_file(server, path, "/etc/openvpn/")
        else
          puts "  File missing 'file_conf' at #{server.file_conf}"
        end
      end

      upload_files = []
      if !server.psk.nil? && File.exist?(server.psk)
        required_file_exist = true
        upload_files << server.psk
      elsif (!server.file_ca_crt.nil? && File.exist?(server.file_ca_crt)) &&
            (!server.file_pem.nil? && File.exist?(server.file_pem)) &&
            (!server.file_crt.nil? && File.exist?(server.file_crt)) &&
            (!server.file_key.nil? && File.exist?(server.file_key))
        required_file_exist = true
        upload_files << server.file_ca_crt
        upload_files << server.file_pem
        upload_files << server.file_crt
        upload_files << server.file_key
      else
        required_file_exist = false
      end

      if required_file_exist
        upload_files.each do |path|
          Netjoin::Interfaces::Linux.upload_file(server, path, "/etc/openvpn/")
        end
      end
      required_file_exist
    end

    private

    def self.generate_site_to_site_conf_file(server, database)
      lines = []
      if server.type == "linux"
        lines << "remote #{database[server.master]['network_ip']}"
        lines << "port 1194"
      end
      lines << "dev tun"
      lines << "persist-tun"
      lines << "persist-local-ip"
      lines << "comp-lzo"
      lines << "user nobody"
      lines << "group nobody"
      lines << "log vpn.log"
      lines << "verb 3"
      lines << "secret /etc/openvpn/#{File.basename(server.psk)}" if File.exist?(server.psk)
      fp = File.open("./server-site.conf", "w")
      fp.write(lines.join("\n"))
      fp.close
      "./server-site.conf"
    end
  end

end
