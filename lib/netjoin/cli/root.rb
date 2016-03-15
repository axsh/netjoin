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

      list_to_provision(db).each do |node_name|
        type = db[:nodes][node_name][:provision][:spec][:type].capitalize
        Netjoin::Drivers.const_get(type).create(node_name)
      end
    end

    no_tasks {
      def list_to_provision(db)
        db[:nodes].inject([]) do |nodes_to_provision, (key, value)|
          if value.include?(:provision)
            nodes_to_provision << key
          end
          nodes_to_provision
        end
      end
    }
  end
end
