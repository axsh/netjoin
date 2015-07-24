#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'thor'

module Ducttape::Cli
  
  class Config < Thor
    
    desc "database <name>", "change the database being used (creates new file when file does not exist yet)"
    def database(name)
      config = Config.loadConfig()        
      config[:database] = name
      Config.writeConfig(config)
      
      if (!File.file?("#{name}.yml"))        
        File.open("#{name}.yml", 'w') {|f| f.write("---") }
      end
      
      puts config.to_yaml()
    end
    
    no_commands {
      def self.loadConfig()
        Ducttape::Cli::Root.loadFile('config.yml')
      end
      
      def self.writeConfig(config)
        Ducttape::Cli::Root.writeFile('config.yml', config)
      end
    }
  end
end