# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

module DucttapeCLI

  class Base < Thor
    
    @type = 'base'

    desc "show","Show all instances"
    def show()

      # Read config file
      config = DucttapeCLI.loadConfig()

      # Remove instances from config that do not match type
      config.each do |key, value|
        if (!(value['type'].to_s === type()))
          config.delete(key)
        end
      end
      puts config.inspect
    end

    no_commands{
      def self.type
        @type
      end

      def type
        self.class.type
      end  
    }

  end

end
