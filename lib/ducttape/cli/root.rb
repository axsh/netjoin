module Ducttape::Cli

  class Root < Thor

    desc "config SUBCOMMAND ...ARGS", "manage configuration"
    subcommand "config", Ducttape::Cli::Config

    desc "clients SUBCOMMAND ...ARGS", "manage clients"
    subcommand "clients", Ducttape::Cli::Clients

    desc "servers SUBCOMMAND ...ARGS", "manage servers"
    subcommand "servers", Ducttape::Cli::Servers

    desc "init", "init ducttape"
    def init()
      if (!File.file?('config.yml'))
        dist_config = Root.load_file('config-dist.yml')
        Root.write_file('config.yml', dist_config.to_yaml)
        puts "Configuration file 'config.yml' created!"
      else
        puts "Configuration file 'config.yml' already exists, skipping!"
      end
      if(!File.file?('database.yml'))
        dist_database = Root.load_file('database-dist.yml')
        Root.write_file('database.yml', dist_database.to_yaml)
        puts "Database file 'database.yml' created!"
      else
        puts "Database file 'database.yml' already exists, skipping!"
      end
    end

    desc "export","Export database"
    def export()
      # Read database file
      database = Root.load_database()
      puts database.to_yaml()
    end

    def self.get_from_config(name)
      config = Root.load_file('config.yml')
      return database = config[name]
    end

    def self.load_database()
      return Root.load_file("#{Root.get_from_config(:database)}.yml")
    end

    def self.write_database(database)
      return Root.write_file("#{Root.get_from_config(:database)}.yml", database.to_yaml)
    end

    def self.load_file(name)
      file = YAML.load_file(name)
      if(!file)
        file = {}
      end
      return file
    end

    def self.write_file(name, data)
      File.open(name,'w') do |h|
        h.write data
      end
    end
  end
end
