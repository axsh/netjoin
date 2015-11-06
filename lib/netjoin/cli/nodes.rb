# -*- coding: utf-8 -*-

require 'thor'

module Netjoin::Cli
  class Nodes < Thor
    include Netjoin::Helpers::Logger

    desc "add <name>", "add a new node"
    option :type, :type => :string
    option :mode, :type => :string
    def add(name)
      info "add #{name}"
      Netjoin::Models::Nodes.create(name, options.to_h)
    end
  end
end
