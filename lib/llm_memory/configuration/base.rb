#!/usr/bin/env ruby
# frozen_string_literal: true

module LlmMemory
  module Config
    # The Base class provides configuration settings for the LlmMemory application.
    #
    # It allows you to set the Redis URL and API endpoint.
    #
    # @example
    #   base_config = LlmMemory::Configuration::Base.new
    #   base_config.api_endpoint = "http://localhost:3000/api"
    class Base
      attr_accessor :pg_url, :redis_url
      # @return [String] The API endpoint.
      attr_accessor :api_endpoint

      # Initializes a new Base configuration instance.
      #
      # Sets the default Redis URL from the environment variable 'REDISCLOUD_URL' or 'redis://localhost:6379' if not set.
      # Sets the API endpoint from the environment variable 'API_ENDPOINT'.
      def initialize
        @redis_url = ENV.fetch('REDIS_URL') || 'redis://localhost:6379'
        @pg_url = ENV.fetch('POSTGRES_URL')
        @api_endpoint = ENV['API_ENDPOINT']
      end
    end
  end
end
