# -*- coding: utf-8 -*-

require 'thor'

module Netjoin::Cli
  class Networks < Thor
    include Netjoin::Helpers::Logger

    desc "add <name>", "add a new network"

    option :network_ip_address, :type => :string
    option :prefix, :type => :numeric

    def add(name)
      info "add #{name}"
      Netjoin::Models::Networks.add(name, options.to_h)
    end

    desc "create <name>", "create a network"
    def create(name)
      info "create #{name}"
      network = Netjoin::Models::Networks.new(name: name)
      network.create
    end
  end
end
