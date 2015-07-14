module DucttapeCLI 
  
  class CLI < Thor
      
    desc "clients SUBCOMMAND ...ARGS", "manage clients"
    subcommand "clients", DucttapeCLI::Clients
    
    desc "servers SUBCOMMAND ...ARGS", "manage servers"
    subcommand "servers", DucttapeCLI::Servers
    
    desc "export","Export database"
    def export()
      # Read database file
      database = CLI.loadDatabase()     
      puts database.inspect
    end
    
    def self.loadDatabase()
      database = YAML.load_file('database.yml')
      if(!database)
        database = {}
      end     
      return database
    end
    
    def self.writeDatabase(database)
      File.open('database.yml','w') do |h| 
        h.write database.to_yaml      
      end
    end
    
  end
  
end
