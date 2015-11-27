# -*- coding: utf-8 -*-

module Netjoin::Models
  class Manifests < Base
    include Netjoin::Helpers::Logger

    def self.validate(options)
      true
    end

    private

    def shape(hash, params)
      hash['manifests'][params[:name]]
    end
  end
end
