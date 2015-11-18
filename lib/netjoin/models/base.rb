# -*- coding: utf-8 -*-

require 'ostruct'
require 'yaml'

module Netjoin::Models
  class Base < OpenStruct
    include Netjoin::Helpers::Constants

    def initialize(params)
      hash = YAML.load_file(DATABASE_YAML)
      super(shape(hash, params))
    end

    def self.add(name, options)
      return if not validate(options)

      hash = YAML.load_file(DATABASE_YAML)
      class_name = self.name.split('::').last.downcase
      hash[class_name].merge!(name => options)

      f = File.open(DATABASE_YAML, 'w')
      f.write(hash.to_yaml)
      f.close

      hash
    end

    def save
      hash = YAML.load_file(DATABASE_YAML)
      class_name = self.class.name.split('::').last.downcase
      hash[class_name][self.name] = Hash[self.to_h.map{|k,v| [k.to_s,v]}]

      File.open(DATABASE_YAML, "w") do |f|
        f.write hash.to_yaml
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
