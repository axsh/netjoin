# -*- coding: utf-8 -*-

module Netjoin::Cli

  class Root < Thor
    include Netjoin::Helpers::Logger
    include Netjoin::Helpers::Constants

    desc "init", "init netjoin"
    def init()
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

    desc "nodes", "manage node"
    subcommand "nodes", Netjoin::Cli::Nodes
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
