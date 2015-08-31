# -*- coding: utf-8 -*-

module Netjoin::Models::Clients

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

    def type()
      return :base
    end

    def export_data()
      raise NotImplementedError
    end

    def export()
      return {
        :type => type(),
        :server => @server,
        :status => @status,
        :error => @error,
        :data => export_data()
      }
    end

    def export_yaml()
      return {
        @name => {

          :type => type(),
          :server => @server,
          :status => @status,
          :error => @error,
          :data => export_data()
        }
      }.to_yaml()
    end

  end
end
