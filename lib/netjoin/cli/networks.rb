# -*- coding: utf-8 -*-

require 'thor'

module Netjoin::Cli
  class Networks < Thor
    include Netjoin::Helpers::Logger

    desc "add <name>", "add a new node"

    option :driver, :type => :string, :required => true
    option :nodes, :type => :string, :required => true

    def add(name)
      info "add #{name}"
      Netjoin::Models::Networks.add(name, options.to_h)
    end

    def create(name)
      info "create #{name}"
      network = Netjoin::Models::Networks.new(name: name)
      network.create
    end
  end
end
