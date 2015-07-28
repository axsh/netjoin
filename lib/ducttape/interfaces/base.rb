# -*- coding: utf-8 -*-

module Ducttape::Interfaces

  class Base

    def self.auth_param(client)
      if (client.key_pem)
        return :keys => client.key_pem
      end
      return :password => client.password
    end

    def self.upload_file(client, source, destination)
      Net::SCP.start(client.ip_address, client.username, Base.auth_param(client)) do |scp|
        scp.upload!(source, destination)
        return true
      end
      return false
    end

  end

end