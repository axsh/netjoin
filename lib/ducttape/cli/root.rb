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
        dist_config = Root.loadFile('config-dist.yml')
        Root.writeFile('config.yml', dist_config)
        puts "Configuration file 'config.yml' created!"
      else
        puts "Configuration file 'config.yml' already exists, skipping!"
      end
      if(!File.file?('database.yml'))
        dist_database = Root.loadFile('database-dist.yml')
        Root.writeFile('database.yml', dist_database)
        puts "Database file 'database.yml' created!"
      else
        puts "Database file 'database.yml' already exists, skipping!"
      end
    end

    desc "export","Export database"
    def export()
      # Read database file
      database = Root.loadDatabase()
      puts database.to_yaml()
    end

    def self.getFromConfig(name)
      config = Root.loadFile('config.yml')
      return database = config[name]
    end

    def self.loadDatabase()
      return Root.loadFile("#{Root.getFromConfig(:database)}.yml")
    end

    def self.writeDatabase(database)
      return Root.writeFile("#{Root.getFromConfig(:database)}.yml", database)
    end

    def self.loadFile(name)
      file = YAML.load_file(name)
      if(!file)
        file = {}
      end
      return file
    end

    def self.writeFile(name, data)
      File.open(name,'w') do |h|
        h.write data.to_yaml
      end
    end
  end
end
