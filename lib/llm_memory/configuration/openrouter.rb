#!/usr/bin/env ruby
# frozen_string_literal: true

module LlmMemory
  module Config
    # The OpenRouter class provides configuration settings for the OpenRouter API.
    #
    # It allows you to set the API key, default model, and host for interacting with the OpenRouter API.
    #
    # @example
    #   openrouter_config = LlmMemory::Configuration::OpenRouter.new
    #   openrouter_config.api_key = "your_openrouter_api_key"
    #   openrouter_config.default_model = "google/gemma-7b-it"
    #   openrouter_config.host = "https://openrouter.ai/api"
    class OpenRouter
      # @return [String] The OpenRouter API key.
      attr_accessor :api_key
      # @return [String] The default OpenRouter model.
      attr_accessor :default_model
      # @return [String] The OpenRouter API host.
      attr_accessor :host

      # Initializes a new OpenRouter configuration instance.
      #
      # Sets the default API key, default model, and host from environment variables.
      #
      # The API key defaults to the 'OPENROUTER_API_KEY' environment variable.
      # The default model defaults to the 'OPENROUTER_DEFAULT_MODEL' environment variable.
      # The host defaults to the 'OPENROUTER_HOST' environment variable or 'https://open_router.ai' if not set.
      def initialize
        @api_key = ENV['OPENROUTER_API_KEY']
        @default_model = ENV['OPENROUTER_DEFAULT_MODEL']
        @host = ENV['OPENROUTER_HOST'] || 'https://open_router.ai'
      end
    end
  end
end
