# frozen_string_literal: true

require 'dotenv/load'
require_relative '../environment.rb'
require 'rom-sql'

module Db
  class Connection
    class UnknownEnvironmentError < StandardError; end

    class << self
      def config
        ROM::Configuration.new(:sql, connection_string, options)
      end

      def container
        ROM.container(config)
      end

      private

      def options
        {
          adapter: :postgres,
          encoding: 'UTF8'
        }
      end

      def connection_string
        if Environment.production?
          ENV.fetch('DATABASE_URL')
        elsif Environment.development?
          user = ENV.fetch('DATABASE_USER')
          password = ENV.fetch('DATABASE_PASSWORD')
          host = ENV.fetch('DATABASE_HOST')
          port = ENV.fetch('DATABASE_PORT', 5432)
          db_name = ENV.fetch('DATABASE_NAME')
          "postgres://#{user}:#{password}@#{host}:#{port}/#{db_name}"
        else
          raise UnknownEnvironmentError
        end
      end
    end
  end
end
