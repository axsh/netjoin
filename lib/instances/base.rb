# -*- coding: utf-8 -*-

module Ducttape::Instances

  class Base

    attr_accessor :name
    attr_accessor :server
    attr_accessor :status
    attr_accessor :error

    def initialize(name, server)
      @name = name
      @server = server
      @status = :new
      @error = nil
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
        :server => @server,
        :status => @status,
        :error => @error,
        :data => getExportData() 
      }
    end

  end
end
