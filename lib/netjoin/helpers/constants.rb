# -*- coding: utf-8 -*-

require 'yaml'

module Netjoin::Helpers
  module Constants
    NETJOIN_ROOT = File.expand_path("../../../../", __FILE__)

    DATABASE_YAML = 'database.yml'
    CONFIG_YAML = 'config.yml'

    GLOBAL_CIDR = ENV['GLOBAL_CIDR']
  end
end
