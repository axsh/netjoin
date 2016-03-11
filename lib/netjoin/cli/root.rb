# -*- coding: utf-8 -*-

module Netjoin::Cli

  class Root < Thor
    include Netjoin::Helpers::Logger
    include Netjoin::Helpers::Constants

    desc "init", "init netjoin"
    def init
      template_dir = "#{NETJOIN_ROOT}/templates"
      [
        {from: "#{template_dir}/config_template.yml", to: CONFIG_YAML},
        {from: "#{template_dir}/database_template.yml", to: DATABASE_YAML}
      ].each do |file|
        if File.exist?(file[:to])
          info "#{file[:to]} exists"
        else
          FileUtils.cp(file[:from], file[:to])
          info "Create #{file[:to]}"
        end
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
