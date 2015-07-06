# -*- coding: utf-8 -*-

module Ducttape::Instances

  class Base

    attr_accessor :name
    
    def initialize(name)
      @name = name
    end
    
    def getType()
      return :base
    end

  end
end
