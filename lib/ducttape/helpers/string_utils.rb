module Ducttape::Helpers

  class StringUtils

    def self.blank?(var)
      if(!var or var.nil? or var.empty?)
        return true
      end
      return false
    end

  end

end