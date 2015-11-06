# -*- coding: utf-8 -*-

require 'ostruct'
require 'yaml'

module Netjoin::Models
  class Base < OpenStruct
    include Netjoin::Helpers::Constants

    def self.create(name, options)
      return if validate(options)

      hash = YAML.load_file(DATABASE_YAML)
      hash['nodes'].merge!(name => options)

      f = File.open(DATABASE_YAML, 'w')
      f.write(hash.to_yaml)
      f.close

      hash
    end

    private

    def self.validate(options)
      raise "NotImplementedError"
    end
  end
end
