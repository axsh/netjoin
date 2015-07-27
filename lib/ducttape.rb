# -*- coding: utf-8 -*-
module Ducttape

  module Cli
  end

  module Models
  end

  module Interfaces
  end

  require_relative 'ducttape/interfaces/linux'
  require_relative 'ducttape/models/clients/linux'
  require_relative 'ducttape/models/servers/linux'
  require_relative 'ducttape/models/servers/aws'

  require_relative 'ducttape/cli/config'
  require_relative 'ducttape/cli/clients'
  require_relative 'ducttape/cli/servers'
  require_relative 'ducttape/cli/root'

end
