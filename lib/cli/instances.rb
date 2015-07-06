# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

require_relative 'instances/linux'

module DucttapeCLI
    
  class Instances < Thor
  
    desc "show","Show all instances"
    options :name => :string
    def show()
      Struct.new("Data", :ip, :username, :password)
      Struct.new("Instance", :type, :data)
      config = YAML.load_file('config.yml')
      if options[:name]
        puts config[options[:name]].inspect
      else
        puts config.inspect
      end
    
    end
       
    desc "delete <name>", "Delete an instance"
    def delete(name)
      Struct.new("Data", :ip, :username, :password)
      Struct.new("Instance", :type, :data)
      config = YAML.load_file('config.yml')
      if(!config[name])
        puts "ERROR : instance with name '#{name}' doest not exist" 
        return
      end
      config.delete(name)
      File.open('config.yml','w') do |h| 
        h.write config.to_yaml      
      end
      puts config.inspect
    end
    
    desc "linux SUBCOMMAND ...ARGS", "manage linux instances"
    subcommand "linux", DucttapeCLI::Linux
    
   end
end