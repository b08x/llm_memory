# frozen_string_literal: true

module LlmMemory
  module Config
    # The Base class provides configuration settings for the LlmMemory application.
    #
    # It allows you to set the PostgreSQL URL, Redis URL, and API endpoint.
    #
    # @example
    #   base_config = LlmMemory::Config::Base.new
    #   base_config.pg_url = "postgres://user:password@host:port/database"
    #   base_config.redis_url = "redis://localhost:6379"
    #   base_config.api_endpoint = "http://localhost:3000/api"
    class Base
      # @return [String, nil] The PostgreSQL URL.
      attr_accessor :pg_url
      # @return [String] The Redis URL.
      attr_accessor :redis_url
      # @return [String, nil] The API endpoint.
      attr_accessor :api_endpoint

      # Initializes a new Base configuration instance.
      #
      # Sets the default Redis URL from the environment variable 'REDIS_URL' or 'redis://localhost:6379' if not set.
      # Sets the PostgreSQL URL from the environment variable 'POSTGRES_URL' or nil if not set.
      # Sets the API endpoint from the environment variable 'API_ENDPOINT' or nil if not set.
      def initialize
        @redis_url = ENV['REDIS_URL']
        @ohm_url = ENV['OHM_URL']
        @pg_url = ENV['POSTGRES_URL']
        @api_endpoint = ENV['API_ENDPOINT']
      end
    end
  end
end
