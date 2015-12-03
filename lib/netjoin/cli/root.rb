# -*- coding: utf-8 -*-

module Netjoin::Cli

  class Root < Thor
    include Netjoin::Helpers::Logger
    include Netjoin::Helpers::Constants

    desc "init", "init netjoin"
    def init
      [
        {file_name: DATABASE_YAML, file_format: DEFAULT_DATABASE_YAML},
        {file_name: CONFIG_YAML, file_format: DEFAULT_CONFIG_YAML}
      ].each do |h|
        if File.exist?(h[:file_name])
          info "#{h[:file_name]} exists"
        else
          f = File.new(h[:file_name], "w")
          f.write(h[:file_format])
          f.close
          info "Create #{h[:file_name]}"
        end
      end
    end

    desc "config", "configure netjoin"
    option :global_cidrs, :type => :array
    def config
      Netjoin.config = Hash[options.to_h.map{|k,v| [k.to_s,v]}]
      File.open(CONFIG_YAML, "w") do |f|
        f.write Netjoin.config.to_yaml
      end
    end

    desc "nodes", "manage node"
    subcommand "nodes", Netjoin::Cli::Nodes

    desc "networks", "manage network"
    subcommand "networks", Netjoin::Cli::Networks

    desc "manifests", "manage manifest"
    subcommand "manifests", Netjoin::Cli::Manifests

    desc "topologies", "manage topology"
    subcommand "topologies", Netjoin::Cli::Topologies
  end
end
