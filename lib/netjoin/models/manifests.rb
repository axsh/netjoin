# -*- coding: utf-8 -*-

module Netjoin::Models
  class Manifests < Base
    include Netjoin::Helpers::Logger

    def self.validate(options)
      true
    end

    def create
      d = Netjoin::Drivers.const_get(self.driver['name'].capitalize)

      self.topologies.each do |t_name|
        t = Netjoin::Models::Topologies.new(name: t_name)
        t.server_nodes.each do |node|
          info "creating #{node}"
          n = Netjoin::Models::Nodes.new(name: node)
          d.install(n, self)
        end
      end
    end

    private

    def shape(hash, params)
      hash['manifests'][params[:name]]
    end
  end
end
