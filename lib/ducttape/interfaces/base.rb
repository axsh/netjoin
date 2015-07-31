# -*- coding: utf-8 -*-

module Ducttape::Interfaces

  class Base

    def self.auth_param(client)
      if (client.key_pem)
        return :keys => client.key_pem
      end
      return :password => client.password
    end
  end
end