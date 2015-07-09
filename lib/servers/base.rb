# -*- coding: utf-8 -*-

module Ducttape::Servers

  class Base

    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def getType()
      return :base
    end

    def getExportData()
      raise NotImplementedError
    end

    def export()
      return {
        :type => getType(),
        :data => getExportData() 
      }
    end

  end
end
