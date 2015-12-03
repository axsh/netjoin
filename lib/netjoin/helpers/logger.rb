# -*- coding: utf-8 -*-

module Netjoin::Helpers
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

    def ssh_exec(ssh, commands)
      ssh.open_channel do |ch|
        ch.request_pty do |ch, success|
          ch.exec commands.join(';') do |ch, success|
            ch.on_data do |ch, data|
              data.chomp.split("\n").each { |d| info d }
            end
          end
        end
      end
    end
  end
end
