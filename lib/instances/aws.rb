# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Instances  
  
  class Aws < Base

    attr_accessor :region
    attr_accessor :access_key
    attr_accessor :secret_key
    
    def initialize(name, region, access_key, secret_key)
      super(name)
      @region = region
      @access_key = access_key
      @secret_key = secret_key
    end

    def getType()
      return :aws
    end

    def getExportData()
      return {
        :region => @region,
        :access_key => @access_key, 
        :secret_key => @secret_key
      }
      
    end

  end

end
