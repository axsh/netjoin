# -*- coding: utf-8 -*-

require 'thor'

module Netjoin::Cli
  class Nodes < Thor
    include Netjoin::Helpers::Logger

    desc "add <name>", "add a new node"

    option :type, :type => :string, :required => true # bare-metal, kvm, aws, softlayer
    option :ssh_ip_address, :type => :string, :required => true
    option :ssh_password, :type => :string
    option :ssh_pem, :type => :string
    option :ssh_from, :type => :string
    option :manifest, :type => :string
    option :provision, :type => :boolean, :required => true

    def add(name)
      info "add #{name}"
      Netjoin::Models::Nodes.create(name, options.to_h)
    end
  end
end
