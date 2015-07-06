# -*- coding: utf-8 -*-

module Ducttape::Interfaces

  class Base

    @name
    
    def setName(name)
      @name = name
    end
    
    def getName()
      return @name
    end
    
    def getType()
      return :type
    end

  end
end
