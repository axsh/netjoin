# -*- coding: utf-8 -*-

module Ducttape::Instances

  class Base

    attr_accessor :name
    attr_accessor :status

    def initialize(name)
      @name = name
      @status = :new
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
        :status => @status,
        :data => getExportData() 
      }
    end

  end
end
