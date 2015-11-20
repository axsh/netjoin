# -*- coding: utf-8 -*-

require 'thor'

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
  end
end
