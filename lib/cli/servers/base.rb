# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

module DucttapeCLI::Server

  class Base < Thor

    @type = 'base'

    desc "show","Show all servers"
    def show()

      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()

      if(!database['servers'])
        return
      end
      # Remove servers from database that do not match type
      database['servers'].each do |key, value|
        if (!(value[:type].to_s === type()))
          database['servers'].delete(key)
        end
      end
      puts database['servers'].inspect
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