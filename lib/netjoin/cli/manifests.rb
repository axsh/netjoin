# -*- coding: utf-8 -*-

require 'thor'

module Netjoin::Cli
  class Manifests < Thor
    include Netjoin::Helpers::Logger

    desc "add <name>", "add a new manifests"

    option :driver, :type => :string, :required => true
    option :type, :type => :string, :required => true
    option :networks :type => :array, :required => true

    def add(name)
      info "add #{name}"
    end
  end
end
