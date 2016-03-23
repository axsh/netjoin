# -*- coding: utf-8 -*-

require 'yaml'

module Netjoin::Helpers
  module Constants
    DATABASE_YAML = 'netjoin.yml'
    CONFIG_YAML = 'netjoin_config.yml'

    GLOBAL_CIDR = ENV['GLOBAL_CIDR']
  end
end
