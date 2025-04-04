# frozen_string_literal: true

module LlmMemory
  module Config
    # The OpenAI class provides configuration settings for the OpenAI API.
    #
    # It allows you to set the API access token, default model, and organization ID for interacting with the OpenAI API.
    #
    # @example
    #   openai_config = LlmMemory::Config::OpenAI.new
    #   openai_config.access_token = "your_openai_api_key"
    #   openai_config.default_model = "gpt-4-turbo-preview"
    #   openai_config.organization_id = "your_openai_organization_id"
    class OpenAI
      # @return [String] The OpenAI API access token.
      attr_accessor :access_token
      # @return [String] The default OpenAI model.
      attr_accessor :default_model
      # @return [String, nil] The OpenAI organization ID.
      attr_accessor :organization_id

      # Initializes a new OpenAI configuration instance.
      #
      # Sets the default API access token, default model, and organization ID from environment variables.
      #
      # The API access token defaults to the 'OPENAI_API_KEY' environment variable.
      # The default model defaults to the 'OPENAI_DEFAULT_MODEL' environment variable or 'gpt-3.5-turbo' if not set.
      # The organization ID defaults to the 'OPENAI_ORGANIZATION_ID' environment variable or nil if not set.
      def initialize
        @access_token = ENV['OPENAI_API_KEY']
        @default_model = ENV['OPENAI_DEFAULT_MODEL'] || 'gpt-3.5-turbo'
        @organization_id = ENV['OPENAI_ORGANIZATION_ID']
      end
    end
  end
end
