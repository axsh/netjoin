# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

module DucttapeCLI::Client

  class Base < Thor
    
    @type = 'base'

    desc "show","Show all clients"
    def show()

      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()

      if(!database['clients'])
        return
      end
      # Remove clients from database that do not match type
      database['clients'].each do |key, value|
        if (!(value[:type].to_s === type()))
          database['clients'].delete(key)
        end
      end
      puts database['clients'].inspect
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
