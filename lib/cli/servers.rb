# -*- coding: utf-8 -*-

require 'thor'

require_relative 'servers/linux'

module DucttapeCLI

  class Servers < Thor

    desc "show","Show all servers"
    options :name => :string
    def show()

      # Read config file
      config = DucttapeCLI.loadConfig()

      # If specific server is asked, show that server only, if not, show all
      if (options[:name])
        puts config['servers'][options[:name]].inspect
      else
        puts config['servers'].inspect
      end

    end 
    
    desc "delete <name>", "Delete server"
    def delete(name)
    
      # Read config file
      config = DucttapeCLI.loadConfig()
    
      # Check for existing instance
      if (!config['servers'] or !config['servers'][name])
        puts "ERROR : server with name '#{name}' doest not exist" 
        return
      end
    
      # Update the config gile
      config['servers'].delete(name)
      DucttapeCLI.writeConfig(config)
    end
      
    desc "linux SUBCOMMAND ...ARGS", "manage Linux servers"
    subcommand "linux", DucttapeCLI::Server::Linux
        
   end
end