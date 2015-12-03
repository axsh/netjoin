# -*- coding: utf-8 -*-

require 'thor'

module Netjoin::Cli
  class Topologies < Thor
    include Netjoin::Helpers::Logger

    desc "add <name>", "add a new topology"

    option :server_nodes, :type => :array
    option :client_nodes, :type => :array

    def add(name)
      info "add #{name}"
      Netjoin::Models::Topologies.add(name, options.to_h)
    end
  end
end
