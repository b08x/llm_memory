#!/usr/bin/env ruby
# frozen_string_literal: true

module LlmMemory
  module Config
    # The OpenAI class provides configuration settings for the OpenAI API.
    #
    # It allows you to set the API key and organization ID for interacting with the OpenAI API.
    #
    # @example
    #   openai_config = LlmMemory::Configuration::OpenAI.new
    #   openai_config.api_key = "your_openai_api_key"
    #   openai_config.organization_id = "your_openai_organization_id"
    class OpenAI
      # @return [String] The OpenAI API key.
      attr_accessor :api_key
      # @return [String] The OpenAI organization ID.
      attr_accessor :organization_id

      # Initializes a new OpenAI configuration instance.
      #
      # Sets the default API key from the environment variable 'OPENAI_API_KEY'.
      # The organization ID is initially set to nil.
      def initialize
        @api_key = ENV['OPENAI_API_KEY']
        @organization_id = nil
      end
    end
  end
end
