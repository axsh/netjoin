#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'thor'

module Netjoin::Cli

  class Config < Thor

    desc "database", "Show or change the database being used (creates new file when file does not exist yet)"
    option :name, :type => :string
    def database()
      config = Config.load_config()

      if(options[:name])
        config[:database] = options[:name]
        Config.write_config(config)

        if (!File.file?("#{options[:name]}.yml"))
          File.open("#{options[:name]}.yml", 'w') do |f|
            f.write("---")
          end
        end
      end

      puts config.to_yaml()
    end

    no_commands {
      def self.load_config()
        Netjoin::Cli::Root.load_file('config.yml')
      end

      def self.write_config(config)
        Netjoin::Cli::Root.write_file('config.yml', config.to_yaml)
      end
    }
  end
end