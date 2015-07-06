# -*- coding: utf-8 -*-

require_relative 'base'

module Ducttape::Instances  
  
  class Linux < Base

    attr_accessor :ip_address
    attr_accessor :username
    attr_accessor :password
    
    def initialize(name, ip_address, username, password)
      super(name)
      @ip_address = ip_address
      @username = username
      @password = password
    end
    
    def export()
      data = Struct::Data.new(@ip_address, @username, @password)
      instance = Struct::Instance.new(getType(), data)
      return instance
    end
    
    def getType()
      return :linux
    end

  end
end
