# -*- coding: utf-8 -*-

module Netjoin
  module Helpers
    module Logger
      def logger
        Netjoin.logger
      end

      def info(msg)
        logger.info msg
      end

      def error(msg)
        logger.error msg
      end

      def debug(msg)
        logger.debug msg
      end

      def warn(msg)
        logger.warn msg
      end
    end
  end
end
