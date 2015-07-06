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
      config = YAML.load_file('config.yml')

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
      config = YAML.load_file('config.yml')

      # Check for existing instance
      if(!config[name])
        puts "ERROR : instance with name '#{name}' doest not exist" 
        return
      end

      # Update the config gile
      config.delete(name)
      File.open('config.yml','w') do |h| 
        h.write config.to_yaml      
      end
    end

    desc "linux SUBCOMMAND ...ARGS", "manage linux instances"
    subcommand "linux", DucttapeCLI::Linux

   end
end