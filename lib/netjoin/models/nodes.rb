# -*- coding: utf-8 -*-

require 'bcrypt'

module Netjoin::Models
  class Nodes < Base
    include Netjoin::Helpers::Logger

    def self.validate(options)
      encrypt_password(options)
    end

    def create
    end

    private

    def shape(hash, params)
      node = hash['nodes'][params[:name]]
      if node['ssh_from']
        ssh_from = node['ssh_from']
        node['ssh_from'] = hash['nodes'][ssh_from]
      end
      node
    end

    def self.encrypt_password(options)
      return if not options['ssh_password']
      options['ssh_password'] = ::BCrypt::Password.create(options['ssh_password']).to_s
    end
  end
end
