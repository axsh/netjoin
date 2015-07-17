# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

module DucttapeCLI::Server

  class Base < Thor

    @type = 'base'

    desc "show","Show all servers"
    option :name, :type => :string
    def show()

      # Read database file
      database = DucttapeCLI::CLI.loadDatabase()

      if(!database['servers'])
        return
      end
      
      # If specific server is asked, show that server only, if not, show all
       if (options[:name])
         if (database['servers'][options[:name]])
           if(database['servers'][options[:name]][:type].to_s === type())
             puts database['servers'][options[:name]].to_yaml()
             return
           else
            puts "ERROR : server with name '#{options[:name]}' does not exist" 
            return
          end
        else
          puts "ERROR : server with name '#{options[:name]}' does not exist" 
          return
        end
      end
      
      # Remove servers from database that do not match type
      database['servers'].each do |key, value|
        if (!(value[:type].to_s === type()))
          database['servers'].delete(key)
        end
      end
      
      puts database['servers'].to_yaml()
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