# -*- coding: utf-8 -*-

require 'thor'

module Netjoin::Cli
  class Manifests < Thor
    include Netjoin::Helpers::Logger

    desc "add <name>", "add a new manifests"

    # ex.) --driver=name:openvpn psk:/path/to/psk
    option :driver, :type => :hash, :required => true
    option :type, :type => :string, :required => true
    option :topologies, :type => :array, :required => true
    # option :server_nodes, :type => :array, :required => true
    # option :client_nodes, :type => :array

    def add(name)
      info "add #{name}"
      Netjoin::Models::Manifests.add(name, options.to_h)
    end

    desc "create <name>", "create and setup nodes according to manifest registered"
    def create(name)
      info "create #{name}"
      manifest = Netjoin::Models::Manifests.new(name: name)
      manifest.create
    end
  end
end
