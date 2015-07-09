# -*- coding: utf-8 -*-

module Ducttape  
  
  class Server

    attr_accessor :ip_address
    
    def initialize(ip_address)
      @ip_address = ip_address
    end
    
    def export()      
      return {
        :ip_address => @ip_address
      }
    end

  end

end
