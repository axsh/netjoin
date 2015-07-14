# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

module DucttapeCLI::Instance

  class Base < Thor
    
    @type = 'base'

    desc "show","Show all instances"
    def show()

      # Read config file
      config = DucttapeCLI.loadConfig()

      if(!config['instances'])
        return
      end
      # Remove instances from config that do not match type
      config['instances'].each do |key, value|
        if (!(value[:type].to_s === type()))
          config['instances'].delete(key)
        end
      end
      puts config['instances'].inspect
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
