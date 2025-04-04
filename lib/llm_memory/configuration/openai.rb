# frozen_string_literal: true

module LlmMemory
  module Config
    # The OpenAI class provides configuration settings for the OpenAI API.
    #
    # It allows you to set the API key and organization ID for interacting with the OpenAI API.
    #
    # @example
    #   openai_config = LlmMemory::Configuration::OpenAI.new
    #   openai_config.access_token = "your_openai_api_key"
    #   openai_config.organization_id = "your_openai_organization_id"
    class OpenAI
      # @return [String] The OpenAI API key.
      attr_accessor :access_token
      # @return [String] The OpenAI organization ID.
      attr_accessor :organization_id

      attr_accessor :default_model

      # Initializes a new OpenAI configuration instance.
      #
      # Sets the default API key from the environment variable 'OPENAI_API_KEY'.
      # The organization ID is initially set to nil.
      def initialize
        @access_token = ENV['OPENAI_API_KEY']
        @default_model = ENV['OPENAI_DEFAULT_MODEL'] || 'gpt-3.5-turbo'
        @organization_id = nil
      end
    end
  end
end
