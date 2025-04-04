#!/usr/bin/env ruby
# frozen_string_literal: true

module LlmMemory
  module Config
    # The Mistral class provides configuration settings for the Mistral API.
    #
    # It allows you to set the API key, default model, and host for interacting with the Mistral API.
    #
    # @example
    #   mistral_config = LlmMemory::Configuration::Mistral.new
    #   mistral_config.api_key = "your_mistral_api_key"
    #   mistral_config.default_model = "mistral-medium"
    #   mistral_config.host = "https://api.mistral.ai"
    class Mistral
      # @return [String] The Mistral API key.
      attr_accessor :api_key
      # @return [String] The default Mistral model.
      attr_accessor :default_model
      # @return [String] The Mistral API host.
      attr_accessor :host

      # Initializes a new Mistral configuration instance.
      #
      # Sets the default API key, default model, and host from environment variables.
      #
      # The API key defaults to the 'MISTRAL_API_KEY' environment variable.
      # The default model defaults to the 'MISTRAL_DEFAULT_MODEL' environment variable.
      # The host defaults to the 'MISTRAL_HOST' environment variable or 'https://api.mistral.ai' if not set.
      def initialize
        @api_key = ENV['MISTRAL_API_KEY']
        @default_model = ENV['MISTRAL_DEFAULT_MODEL'] || 'mistral-large'
        @host = ENV['MISTRAL_HOST'] || 'https://api.mistral.ai'
      end
    end
  end
end
