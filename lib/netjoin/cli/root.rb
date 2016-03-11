# -*- coding: utf-8 -*-

require 'yaml'

module Netjoin::Cli

  class Root < Thor
    include Netjoin::Helpers::Logger
    include Netjoin::Helpers::Constants

    desc "init", "init netjoin"
    def init
      template_dir = "#{Netjoin::ROOT}/templates"
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

    desc "up", "provision resources"
    def up
      Netjoin.db = YAML.load_file(DATABASE_YAML).symbolize_keys
      Netjoin.config = YAML.load_file(CONFIG_YAML).symbolize_keys
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
