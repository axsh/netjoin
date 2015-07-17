# -*- coding: utf-8 -*-

require 'thor'

require_relative 'servers/linux'

module DucttapeCLI

  class Servers < Thor

    desc "show","Show all servers"
    option :name, :type => :string
    def show()

      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()

      # If specific server is asked, show that server only, if not, show all
      if (options[:name])
        if (!database['servers'][options[:name]])
          puts "ERROR : server with name '#{options[:name]}' does not exist" 
          return
        end
        puts database['servers'][options[:name]].to_yaml()
      else
        puts database['servers'].to_yaml()
      end

    end 
    
    desc "delete <name>", "Delete server"
    def delete(name)
    
      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()
    
      # Check for existing server
      if (!database['servers'] or !database['servers'][name])
        puts "ERROR : server with name '#{name}' does not exist" 
        return
      end
    
      # Update the database gile
      database['servers'].delete(name)
      DucttapeCLI::CLI.writeDatabase(database)
      puts database['servers'].to_yaml()
    end
      
    desc "linux SUBCOMMAND ...ARGS", "manage Linux servers"
    subcommand "linux", DucttapeCLI::Server::Linux
  
   end
end