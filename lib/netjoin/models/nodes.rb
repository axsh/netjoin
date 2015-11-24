# -*- coding: utf-8 -*-

require 'bcrypt'

module Netjoin::Models
  class Nodes < Base
    include Netjoin::Helpers::Logger

    def self.validate(options)
      options['prefix'] = 24 if options['prefix'].nil?
      #encrypt_password(options)
    end

    def create
      if provision
        Netjoin::Drivers.const_get(self.type.capitalize).create(self)
      else
        info "seems the node is already provisioned: #{name}"
      end
    end

    private

    def shape(hash, params)
      node = hash['nodes'][params[:name]]
      node['name'] = params[:name]
      node
    end

    def self.encrypt_password(options)
      return if not options['ssh_password']
      options['ssh_password'] = ::BCrypt::Password.create(options['ssh_password']).to_s
    end
  end
end
