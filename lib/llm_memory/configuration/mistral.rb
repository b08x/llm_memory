#!/usr/bin/env ruby
# frozen_string_literal: true

module LlmMemory
  module Config
    # The Mistral class provides configuration settings for the Mistral API.
    #
    # It allows you to set the API access token, default model, and base URI for interacting with the Mistral API.
    #
    # @example
    #   mistral_config = LlmMemory::Config::Mistral.new
    #   mistral_config.access_token = "your_mistral_api_key"
    #   mistral_config.default_model = "mistral-medium"
    #   mistral_config.uri_base = "https://api.mistral.ai"
    class Mistral
      # @return [String] The Mistral API access token.
      attr_accessor :access_token
      # @return [String] The default Mistral model.
      attr_accessor :default_model
      # @return [String] The base URI for the Mistral API.
      attr_accessor :uri_base

      # Initializes a new Mistral configuration instance.
      #
      # Sets the default API access token, default model, and base URI from environment variables.
      #
      # The API access token defaults to the 'MISTRAL_API_KEY' environment variable.
      # The default model defaults to the 'MISTRAL_DEFAULT_MODEL' environment variable or 'mistral-large' if not set.
      # The base URI defaults to the 'MISTRAL_BASE_URI' environment variable or 'https://api.mistral.ai' if not set.
      def initialize
        @access_token = ENV['MISTRAL_API_KEY']
        @default_model = ENV['MISTRAL_DEFAULT_MODEL'] || 'mistral-large'
        @uri_base = ENV['MISTRAL_BASE_URI'] || 'https://api.mistral.ai'
      end
    end
  end
end
