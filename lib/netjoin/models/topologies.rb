# -*- coding: utf-8 -*-

module Netjoin::Models
  class Topologies < Base
    include Netjoin::Helpers::Logger

    def self.validate(options)
      true
    end

    private

    def shape(hash, params)
      hash['topologies'][params[:name]]
    end
  end
end
