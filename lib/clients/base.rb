# -*- coding: utf-8 -*-

module Ducttape::Clients

  class Base

    attr_accessor :name
    attr_accessor :server
    attr_accessor :status
    attr_accessor :error

    def initialize(name, server, status = :new, error = nil)
      @name = name
      @server = server
      @status = status
      @error = error
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
    
    def export_yaml()
      return {
        @name => {
  
          :type => getType(),
          :server => @server,
          :status => @status,
          :error => @error,
          :data => getExportData() 
        }
      }.to_yaml()
    end

  end
end
