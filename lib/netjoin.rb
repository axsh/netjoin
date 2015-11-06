# -*- coding: utf-8 -*-

require 'logger'

module Netjoin

  class << self
    attr_accessor :logger
  end

  module Cli
    autoload :Root,   'netjoin/cli/root'
    autoload :Nodes,  'netjoin/cli/nodes'
  end

  module Models
    autoload :Base,   'netjoin/models/base'
    autoload :Nodes,  'netjoin/models/nodes'
  end

  module Interfaces
  end

  module Helpers
    autoload :Logger,     'netjoin/helpers/logger'
    autoload :Constants,  'netjoin/helpers/constants'
  end
end

Netjoin.logger = ::Logger.new(STDOUT)
