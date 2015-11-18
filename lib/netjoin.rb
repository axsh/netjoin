# -*- coding: utf-8 -*-

require 'logger'

module Netjoin

  ROOT = ENV['NETJOIN_ROOT'] || File.expand_path("../../", __FILE__)

  class << self
    attr_accessor :logger
  end

  module Cli
    autoload :Root,      'netjoin/cli/root'
    autoload :Nodes,     'netjoin/cli/nodes'
    autoload :Networks,  'netjoin/cli/networks'
  end

  module Models
    autoload :Base,      'netjoin/models/base'
    autoload :Nodes,     'netjoin/models/nodes'
    autoload :Networks,  'netjoin/models/networks'
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
