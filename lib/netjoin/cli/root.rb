# -*- coding: utf-8 -*-

require 'yaml'
require 'net/ssh'
require 'net/ssh/proxy/command'

module Netjoin::Cli

  class Root < Thor
    include Netjoin::Helpers::Logger
    include Netjoin::Helpers::Constants

    desc "init", "init netjoin"
    def init
      template_dir = "#{Netjoin::ROOT}/templates"
      [
        {from: "#{template_dir}/config_template.yml", to: CONFIG_YAML},
        {from: "#{template_dir}/database_template.yml", to: DATABASE_YAML}
      ].each do |file|
        if File.exist?(file[:to])
          info "#{file[:to]} exists"
        else
          FileUtils.cp(file[:from], file[:to])
          info "Create #{file[:to]}"
        end
      end
    end

    desc "up", "provision resources"
    def up
      list_to_provision(db).each do |node_name|
        type = db[:nodes][node_name][:provision][:spec][:type].capitalize
        Netjoin::Drivers.const_get(type).create(node_name)
      end
    end

    desc "show_ip", "show ip address for specific type"
    def show_ip(type)
      ips = []
      db[:nodes].each do |key, value|
        if value.include?(:provision) && value[:provision][:spec][:type] == type
          value[:provision][:spec][:nics].each do |k, v|
            ips << v[:ipaddr]
          end
        end
      end
      p ips
    end

    desc "setup_tunnel", "setup_tunnel"
    def setup_tunnel(type, ip)
      node = db[:nodes].select {|k,v| v.include?(:provision) && v[:provision][:spec][:type] == type }.first.last

      ssh_options = {}

      if node[:ssh].include?(:from)
        parent = db[:nodes][node[:ssh][:from].to_sym]

        proxy = Net::SSH::Proxy::Command.new("
          ssh #{parent[:ssh][:ip]} \
            -l #{parent[:ssh][:user]} \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -W %h:%p -i #{parent[:ssh][:key]}
        ")

        ssh_options[:proxy] = proxy
      end

      ssh_options[:keys] = [node[:ssh][:key]]
      ssh_options[:user_known_hosts_file] = "/dev/null"
      ssh_options[:paranoid] = false

      Net::SSH.start(node[:ssh][:ip], node[:ssh][:user], ssh_options) do |ssh|
        ssh_exec(ssh, [
          "tun=`cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1`; sudo ovs-vsctl add-port brtun g${tun} -- set interface g${tun} type=gre options:remote_ip=#{ip}"
        ])
      end
    end

    no_tasks {
      def list_to_provision(db)
        db[:nodes].inject([]) do |nodes_to_provision, (key, value)|
          if value.include?(:provision) && (!value[:provision].include?(:provisioned) || value[:provision][:provisioned] == false)
            nodes_to_provision << key
          end
          nodes_to_provision
        end
      end
    }
  end
end
