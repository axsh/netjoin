# -*- coding: utf-8 -*-

module Netjoin::Models
  class Topologies < Base
    include Netjoin::Helpers::Logger

    def self.validate(options)
      true
    end

    def self.get_all_server_nodes
      server_nodes = []
      Netjoin.db['topologies'].each do |k,v|
        v['server_nodes'].each { |b| server_nodes << b }
      end
      server_nodes.uniq
    end

    def self.get_all_server_nodes_except(name)
      get_all_server_nodes.select { |n| n != name }
    end

    private

    def shape(hash, params)
      hash['topologies'][params[:name]]
    end
  end
end
