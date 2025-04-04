# frozen_string_literal: true

module LlmMemory
  module Config
    # The Gemini class provides configuration settings for the Gemini API.
    #
    # It allows you to set the API key and default model for interacting with the Gemini API.
    #
    # @example
    #   gemini_config = LlmMemory::Configuration::Gemini.new
    #   gemini_config.api_key = "your_gemini_api_key"
    #   gemini_config.default_model = "gemini-pro"
    class HuggingFace
      # @return [String] The Gemini API key.
      attr_accessor :api_token

      attr_accessor :default_model

      # @return [String] The default HF embedding model.
      attr_accessor :embedding_model

      # Initializes a new Gemini configuration instance.
      #
      # Sets the default API key and default model from environment variables.
      #
      # The API key defaults to the 'GEMINI_API_KEY' environment variable.
      # The default model defaults to the 'GEMINI_DEFAULT_MODEL' environment variable.
      def initialize
        @api_token = ENV.fetch('HUGGING_FACE_API_TOKEN')
        @default_model = ENV.fetch('HUGGING_FACE_DEFAULT_MODEL') || 'Qwen/Qwen2.5-Coder-32B-Instruct'
        @embedding_model = ENV.fetch('HUGGING_FACE_EMBEDDING_MODEL') || 'sentence-transformers/all-MiniLM-L6-v2'
      end
    end
  end
end
