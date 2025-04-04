# frozen_string_literal: true

module LlmMemory
  module Config
    # The Gemini class provides configuration settings for the Gemini API.
    #
    # It allows you to set the API access token and default model for interacting with the Gemini API.
    #
    # @example
    #   gemini_config = LlmMemory::Config::Gemini.new
    #   gemini_config.access_token = "your_gemini_api_key"
    #   gemini_config.default_model = "gemini-pro"
    class Gemini
      # @return [String] The Gemini API access token.
      attr_accessor :api_key
      # @return [String] The default Gemini model.
      attr_accessor :default_model
      attr_accessor :embedding_model

      # Initializes a new Gemini configuration instance.
      #
      # Sets the default API access token and default model from environment variables.
      #
      # The API access token defaults to the 'GEMINI_API_KEY' environment variable.
      # The default model defaults to the 'GEMINI_DEFAULT_MODEL' environment variable or 'gemini-2.0-flash' if not set.
      def initialize
        @api_key = ENV.fetch('GEMINI_API_KEY')
        @default_model = ENV.fetch('GEMINI_DEFAULT_MODEL') || 'gemini-2.0-flash'
        @embedding_model = ENV.fetch('GEMINI_EMBEDDING_MODEL') || 'text-embedding-004'
      end
    end
  end
end
