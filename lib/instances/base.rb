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

    def getExportData()
      raise NotImplementedError
    end

    def export()
      instance = Struct::Instance.new(getType(), getExportData())
      return instance
    end

  end
end
