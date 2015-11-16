# -*- coding: utf-8 -*-

module Netjoin::Models
  class Networks < Base
    include Netjoin::Helpers::Logger

    def initialize(params)
      super(params)
    end

    def self.validate(options)
      true
    end

    def create
      d = Netjoin::Drivers.const_get(self.driver.capitalize)
      self.nodes.each do |node|
        n = Netjoin::Models::Nodes.new(name: node)
        d.install(n, self)
      end
    end

    def shape(hash, params)
      hash['networks'][params[:name]]
    end
  end
end
