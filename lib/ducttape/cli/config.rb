#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'thor'

module Ducttape::Cli

  class Config < Thor

    desc "database <name>", "change the database being used (creates new file when file does not exist yet)"
    def database(name)
      config = Config.load_config()
      config[:database] = name
      Config.write_config(config)

      if (!File.file?("#{name}.yml"))
        File.open("#{name}.yml", 'w') {|f| f.write("---") }
      end

      puts config.to_yaml()
    end

    no_commands {
      def self.load_config()
        Ducttape::Cli::Root.load_file('config.yml')
      end

      def self.write_config(config)
        Ducttape::Cli::Root.write_file('config.yml', config)
      end
    }
  end
end