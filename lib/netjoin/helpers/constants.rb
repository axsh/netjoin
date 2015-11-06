# -*- coding: utf-8 -*-

require 'yaml'

module Netjoin::Helpers
  module Constants
    DATABASE_YAML = 'database.yml'
    CONFIG_YAML = 'config.yml'

    DEFAULT_DATABASE_YAML = {'nodes' => {}, 'manifests' => {}}.to_yaml
    DEFAULT_CONFIG_YAML = {'configs' => {}}.to_yaml
  end
end
