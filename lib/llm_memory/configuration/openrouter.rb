#!/usr/bin/env ruby
# frozen_string_literal: true

module LlmMemory
  module Config
    # The OpenRouter class provides configuration settings for the OpenRouter API.
    #
    # It allows you to set the API key, default model, and base URI for interacting with the OpenRouter API.
    #
    # @example
    #   openrouter_config = LlmMemory::Configuration::OpenRouter.new
    #   openrouter_config.access_token = "your_openrouter_api_key"
    #   openrouter_config.default_model = "google/gemma-7b-it"
    #   openrouter_config.uri_base = "https://openrouter.ai/api"
    class OpenRouter
      # @return [String] The OpenRouter API access token.
      attr_accessor :access_token
      # @return [String] The default OpenRouter model.
      attr_accessor :default_model
      # @return [String] The base URI for the OpenRouter API.
      attr_accessor :uri_base

      # Initializes a new OpenRouter configuration instance.
      #
      # Sets the default API access token, default model, and base URI from environment variables.
      #
      # The API access token defaults to the 'OPENROUTER_API_KEY' environment variable.
      # The default model defaults to the 'OPENROUTER_DEFAULT_MODEL' environment variable or 'google/gemini-2.0-flash-001' if not set.
      # The base URI defaults to the 'OPENROUTER_BASE_URI' environment variable or 'https://openrouter.ai' if not set.
      def initialize
        @access_token = ENV['OPENROUTER_API_KEY']
        @default_model = ENV['OPENROUTER_DEFAULT_MODEL'] || 'google/gemini-2.0-flash-001'
        @uri_base = ENV['OPENROUTER_BASE_URI'] || 'https://openrouter.ai'
      end
    end
  end
end
