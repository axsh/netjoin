# -*- coding: utf-8 -*-

module Netjoin::Models
  class Manifests < Base
    include Netjoin::Helpers::Logger

    def self.validate(options)
      true
    end

    def create
      d = Netjoin::Drivers.const_get(self.driver['name'].capitalize)

      self.nodes.each do |node|
        info "creating #{node}"
        d.install(Netjoin::Models::Nodes.new(name: node), self)
      end
    end

    private

    def shape(hash, params)
      hash['manifests'][params[:name]]
    end
  end
end
