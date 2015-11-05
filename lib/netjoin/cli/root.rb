# -*- coding: utf-8 -*-

require 'fileutils'

module Netjoin::Cli

  class Root < Thor
    include Netjoin::Helpers::Logger

    desc "init", "init netjoin"
    def init()
      ['config', 'database'].each do |name|
        if File.exist?("#{name}.yml")
          info "#{name}.yml exists"
        else
          FileUtils.cp("#{name}-dist.yml", "#{name}.yml")
          info "create #{name}.yml"
        end
      end
    end

    # desc "config SUBCOMMAND ...ARGS", "manage configuration"
    # subcommand "config", Netjoin::Cli::Config

    # desc "clients SUBCOMMAND ...ARGS", "manage clients"
    # subcommand "clients", Netjoin::Cli::Clients

    # desc "servers SUBCOMMAND ...ARGS", "manage servers"
    # subcommand "servers", Netjoin::Cli::Servers


    # desc "export","Export database"
    # def export()
    #   # Read database file
    #   database = Root.load_database()
    #   puts database.to_yaml()
    # end

    # def self.get_from_config(name)
    #   config = Root.load_file('config.yml')
    #   return database = config[name]
    # end

    # def self.load_database()
    #   return Root.load_file("#{Root.get_from_config(:database)}.yml")
    # end

    # def self.write_database(database)
    #   return Root.write_file("#{Root.get_from_config(:database)}.yml", database.to_yaml)
    # end

    # def self.load_file(name)
    #   file = YAML.load_file(name)
    #   if(!file)
    #     file = {}
    #   end
    #   return file
    # end

    # def self.write_file(name, data)
    #   File.open(name,'w') do |h|
    #     h.write data
    #   end
    # end
  end
end
