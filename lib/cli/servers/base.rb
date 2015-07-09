# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

module DucttapeCLI::Server

  class Base < Thor

    @type = 'base'

    desc "show","Show all servers"
    def show()

      # Read config file
      config = DucttapeCLI.loadConfig()

      if(!config['servers'])
        return
      end
      # Remove servers from config that do not match type
      config['servers'].each do |key, value|
        if (!(value['type'].to_s === type()))
          config['servers'].delete(key)
        end
      end
      puts config['servers'].inspect
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