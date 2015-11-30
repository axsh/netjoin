# -*- coding: utf-8 -*-

module Netjoin::Models
  class Manifests < Base
    include Netjoin::Helpers::Logger

    def self.validate(options)
      true
    end

    def create
      d = Netjoin::Drivers.const_get(self.driver['name'].capitalize)
      self.server_nodes.each do |node|
        info "creating #{node}"
        n = Netjoin::Models::Nodes.new(name: node)
        d.install(n, self)
      end

      if not client_nodes && client_nodes.empty?
        # do something for clients
      end
    end

    private

    def shape(hash, params)
      hash['manifests'][params[:name]]
    end
  end
end
