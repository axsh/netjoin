# -*- coding: utf-8 -*-
module Netjoin

  module Cli
  end

  module Models
  end

  module Interfaces
  end

  module Helpers
  end

  require_relative 'netjoin/helpers/string_utils'

  require_relative 'netjoin/interfaces/linux'
  require_relative 'netjoin/models/clients/linux'
  require_relative 'netjoin/models/servers/linux'
  require_relative 'netjoin/models/servers/aws'

  require_relative 'netjoin/cli/config'
  require_relative 'netjoin/cli/clients'
  require_relative 'netjoin/cli/servers'
  require_relative 'netjoin/cli/root'

end
