# -*- coding: utf-8 -*-

require 'thor'
require 'net/ssh'

module Netjoin::Cli
  class Nodes < Thor
    include Netjoin::Helpers::Logger

    desc "add <name>", "add a new node"

    option :type, :type => :string, :required => true # bare-metal, kvm, aws, softlayer
    option :ssh_ip_address, :type => :string
    option :prefix, :type => :numeric
    option :ssh_user, :type => :string
    option :ssh_privatekey, :type => :string
    option :parent, :type => :string
    option :provision, :type => :boolean

    option :access_key_id, :type => :string
    option :secret_key, :type => :string
    option :ami, :type => :string
    option :instance_type, :type => :string
    option :key_pair, :type => :string
    option :region, :type => :string
    option :security_groups, :type => :array
    option :vpc_id, :type => :string
    option :zone, :type => :string

    option :networks, :type => :array

    def add(name)
      info "add #{name}"
      Netjoin::Models::Nodes.add(name, options.to_h)
    end

    desc "create <name>", "create a node"

    def create(name)
      info "create #{name}"
      node = Netjoin::Models::Nodes.new(name: name)
      node.create
    end

    desc "setup <name>", "setup a client node according to vpn server"

    option :ssh_ip_address,   :type => :string, :required => true
    option :ssh_user,         :type => :string, :required => true
    option :ssh_privatekey,   :type => :string, :required => true
    option :server_node,      :type => :string, :required => true
    option :local_ip_address, :type => :string, :required => true

    def setup
      n = Netjoin::Models::Nodes.new(name: options['server_node'])

      Net::SSH.start(
        options['ssh_ip_address'],
        options['ssh_user'],
        :keys => [options['ssh_privatekey']]) do |ssh|

        commands = []
        commands << "sudo ovs-vsctl --may-exist add-port brtun t-aws -- set interface t-aws type=gre options:remote_ip=#{n.local_ip}"
        ssh_exec(ssh, commands)
      end

      Net::SSH.start(
        n.ssh_ip_address,
        n.ssh_user,
        :keys => [n.privatekey_file_name]) do |ssh|

        commands = []
        commands << "sudo ovs-vsctl --may-exist add-port brtun t-local -- set interface t-local type=gre options:remote_ip=#{options['local_ip_address']}"
        ssh_exec(ssh, commands)
      end
    end
  end
end
