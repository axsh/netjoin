# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

require_relative 'instances/aws'
require_relative 'instances/linux'

module DucttapeCLI

  class Instances < Thor

    desc "show","Show all instances"
    options :name => :string
    def show()

      # Read config file
      config = DucttapeCLI.loadConfig()

      # If specific instance is asked, show that instance only, if not, show all
      if (options[:name])
        puts config[options[:name]].inspect
      else
        puts config.inspect
      end

    end

    desc "delete <name>", "Delete an instance"
    def delete(name)

      # Read config file
      config = DucttapeCLI.loadConfig()

      # Check for existing instance
      if (!config[name])
        puts "ERROR : instance with name '#{name}' doest not exist" 
        return
      end

      # Update the config gile
      config.delete(name)
      DucttapeCLI.writeConfig(config)
    end
    
    desc "aws SUBCOMMAND ...ARGS", "manage AWS instances"
    subcommand "aws", DucttapeCLI::Aws
    desc "linux SUBCOMMAND ...ARGS", "manage Linux instances"
    subcommand "linux", DucttapeCLI::Linux

   end
end