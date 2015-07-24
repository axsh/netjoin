# -*- coding: utf-8 -*-

module Ducttape::Models::Servers

  class Base

    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def type()
      return :base
    end

    def export_data()
      return {}
    end

    def export()
      return {
        :type => type(),
        :data => export_data()
      }
    end

    def export_yaml()
      return {
        @name => {
          :type => type(),
          :data => export_data()
        }
      }.to_yaml()
    end

  end
end
