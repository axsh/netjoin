# -*- coding: utf-8 -*-

require 'thor'

require_relative 'servers/linux'

module DucttapeCLI

  class Servers < Thor

    desc "show","Show all servers"
    options :name => :string
    def show()

      # Read database file
      database = DucttapeCLI.loadDatabase()

      # If specific server is asked, show that server only, if not, show all
      if (options[:name])
        puts database['servers'][options[:name]].inspect
      else
        puts database['servers'].inspect
      end

    end 
    
    desc "delete <name>", "Delete server"
    def delete(name)
    
      # Read database file
      database = DucttapeCLI.loadDatabase()
    
      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' doest not exist" 
        return
      end
    
      # Update the database gile
      database['servers'].delete(name)
      DucttapeCLI.writeDatabase(database)
    end
      
    desc "linux SUBCOMMAND ...ARGS", "manage Linux servers"
    subcommand "linux", DucttapeCLI::Server::Linux
        
   end
end