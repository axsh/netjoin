require 'resolv'

module Ducttape::Helpers

  class StringUtils

    def self.blank?(var)
      if(!var or var.nil? or var.empty?)
        return true
      end
      return false
    end

    def self.valid_ip_address?(var)
      case var
      when Resolv::IPv4::Regex
        return true
#      when Resolv::IPv6::Regex
#        return true
      end
      return false;
    end

  end

end