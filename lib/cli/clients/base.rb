# -*- coding: utf-8 -*-

require 'thor'
require 'yaml'

module Ducttape::Cli::Client

  class Base < Thor
    
    @type = 'base'

    desc "show","Show all clients"
    option :name, :type => :string
    def show()

      # Read database file
      database = Ducttape::Cli::Root.loadDatabase()
      if(!database['clients'])
        return
      end
      
      # If specific client is asked, show that client only, if not, show all
       if (options[:name])
         if (database['clients'][options[:name]])
           if(database['clients'][options[:name]][:type].to_s === type())
             puts database['clients'][options[:name]].to_yaml()
             return
           else
            puts "ERROR : client with name '#{options[:name]}' does not exist" 
            return
          end
        else
          puts "ERROR : client with name '#{options[:name]}' does not exist" 
          return
        end       
      end
      
      # Remove clients from database that do not match type
      database['clients'].each do |key, value|
        if (!(value[:type].to_s === type()))
          database['clients'].delete(key)
        end
      end
      
      puts database['clients'].to_yaml()
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
