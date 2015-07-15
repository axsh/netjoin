module DucttapeCLI 
  
  class CLI < Thor
    
    desc "config SUBCOMMAND ...ARGS", "manage configuration"
    subcommand "config", DucttapeCLI::Config
          
    desc "clients SUBCOMMAND ...ARGS", "manage clients"
    subcommand "clients", DucttapeCLI::Clients
    
    desc "servers SUBCOMMAND ...ARGS", "manage servers"
    subcommand "servers", DucttapeCLI::Servers
    
    desc "init", "init ducttape"
    def init()
      if (!File.file?('config.yml'))
        dist_config = CLI.loadFile('config-dist.yml')
        CLI.writeFile('config.yml', dist_config)
        puts "Configuration file 'config.yml' created!"
      else
        puts "Configuration file 'config.yml' already exists, skipping!"
      end
      if(!File.file?('database.yml'))
        dist_database = CLI.loadFile('database-dist.yml')
        CLI.writeFile('database.yml', dist_database)
        puts "Database file 'database.yml' created!"
      else
        puts "Database file 'database.yml' already exists, skipping!"
      end
    end
    
    desc "export","Export database"
    def export()
      # Read database file
      database = CLI.loadDatabase()     
      puts database.to_yaml()
    end
    
    def self.getFromConfig(name)
      config = CLI.loadFile('config.yml')
      return database = config[name]
    end
    
    def self.loadDatabase()      
      return CLI.loadFile("#{CLI.getFromConfig(:database)}.yml")
    end
    
    def self.writeDatabase(database)
      return CLI.writeFile("#{CLI.getFromConfig(:database)}.yml", database)
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
