# -*- coding: utf-8 -*-

require 'logger'
require 'yaml'

module Netjoin

  ROOT = ENV['NETJOIN_ROOT'] || File.expand_path("../../", __FILE__)

  class << self
    attr_accessor :logger
    attr_accessor :db
    attr_accessor :config
  end

  module Cli
    autoload :Root,        'netjoin/cli/root'
    autoload :Nodes,       'netjoin/cli/nodes'
    autoload :Networks,    'netjoin/cli/networks'
    autoload :Manifests,   'netjoin/cli/manifests'
    autoload :Topologies,  'netjoin/cli/topologies'
  end

  module Models
    autoload :Base,        'netjoin/models/base'
    autoload :Nodes,       'netjoin/models/nodes'
    autoload :Networks,    'netjoin/models/networks'
    autoload :Manifests,   'netjoin/models/manifests'
    autoload :Topologies,  'netjoin/models/topologies'
  end

  module Drivers
    autoload :Openvpn,   'netjoin/drivers/openvpn'
    autoload :Kvm,       'netjoin/drivers/kvm'
    autoload :Aws,       'netjoin/drivers/aws'
  end

  module Helpers
    autoload :Logger,     'netjoin/helpers/logger'
    autoload :Constants,  'netjoin/helpers/constants'
  end
end

Netjoin.logger = ::Logger.new(STDOUT)
Netjoin.db ||= YAML.load_file(Netjoin::Helpers::Constants::DATABASE_YAML)
Netjoin.config ||= YAML.load_file(Netjoin::Helpers::Constants::CONFIG_YAML)
