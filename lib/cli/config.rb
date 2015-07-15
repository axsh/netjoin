#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'thor'

module DucttapeCLI
  
  class Config < Thor
    
    desc "database <name>", "change the atabase being used"
    def database(name)
      config = Config.loadConfig()        
      config[:database] = name
      Config.writeConfig(config)
      puts config.to_yaml()
    end
    
    no_commands {
      def self.loadConfig()
        DucttapeCLI::CLI.loadFile('config.yml')
      end
      
      def self.writeConfig(config)
        DucttapeCLI::CLI.writeFile('config.yml', config)
      end
    }
  end
end