# -*- coding: utf-8 -*-

require 'ostruct'

module Netjoin::Models
  class Base < OpenStruct
    include Netjoin::Helpers::Constants

    def initialize(params)
      super(shape(Netjoin.db, params))
    end

    def self.add(name, options)
      return if not validate(options)

      class_name = self.name.split('::').last.downcase
      Netjoin.db[class_name].merge!(name => options)

      File.open(DATABASE_YAML, "w") do |f|
        f.write Netjoin.db.to_yaml
      end

      Netjoin.db
    end

    def save
      class_name = self.class.name.split('::').last.downcase
      Netjoin.db[class_name][self.name] = Hash[self.to_h.map{|k,v| [k.to_s,v]}]

      File.open(DATABASE_YAML, "w") do |f|
        f.write Netjoin.db.to_yaml
      end
    end

    private

    def shape(hash, params)
      raise "NotImplementedError"
    end

    def self.validate(options)
      raise "NotImplementedError"
    end
  end
end
