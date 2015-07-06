# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

require_relative 'instances/linux'

module DucttapeCLI

  class Instances < Thor

    desc "show","Show all instances"
    options :name => :string
    def show()

      # Read config file
      Struct.new("Data", :ip, :username, :password)
      Struct.new("Instance", :type, :data)
      config = DucttapeCLI.loadConfig()

      # If specific instance is asked, show that instance only, if not, show all
      if options[:name]
        puts config[options[:name]].inspect
      else
        puts config.inspect
      end

    end

    desc "delete <name>", "Delete an instance"
    def delete(name)

      # Read config file
      Struct.new("Data", :ip, :username, :password)
      Struct.new("Instance", :type, :data)
      config = DucttapeCLI.loadConfig()

      # Check for existing instance
      if(!config[name])
        puts "ERROR : instance with name '#{name}' doest not exist" 
        return
      end

      # Update the config gile
      config.delete(name)
      DucttapeCLI.writeConfig(config)
    end

    desc "linux SUBCOMMAND ...ARGS", "manage linux instances"
    subcommand "linux", DucttapeCLI::Linux

   end
end