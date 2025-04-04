# frozen_string_literal: true

module LlmMemory
  module Config
    # The HuggingFace class provides configuration settings for the Hugging Face API.
    #
    # It allows you to set the API access token, default model, and default embedding model for interacting with the Hugging Face API.
    #
    # @example
    #   huggingface_config = LlmMemory::Config::HuggingFace.new
    #   huggingface_config.access_token = "your_huggingface_api_token"
    #   huggingface_config.default_model = "Qwen/Qwen2.5-Coder-32B-Instruct"
    #   huggingface_config.embedding_model = "sentence-transformers/all-MiniLM-L6-v2"
    class HuggingFace
      # @return [String] The Hugging Face API access token.
      attr_accessor :access_token
      # @return [String] The default Hugging Face model.
      attr_accessor :default_model
      # @return [String] The default Hugging Face embedding model.
      attr_accessor :embedding_model

      # Initializes a new HuggingFace configuration instance.
      #
      # Sets the default API access token, default model, and default embedding model from environment variables.
      #
      # The API access token defaults to the 'HUGGING_FACE_API_TOKEN' environment variable.
      # The default model defaults to the 'HUGGING_FACE_DEFAULT_MODEL' environment variable or 'Qwen/Qwen2.5-Coder-32B-Instruct' if not set.
      # The default embedding model defaults to the 'HUGGING_FACE_EMBEDDING_MODEL' environment variable or 'sentence-transformers/all-MiniLM-L6-v2' if not set.
      def initialize
        @access_token = ENV.fetch('HUGGING_FACE_API_TOKEN')
        @default_model = ENV.fetch('HUGGING_FACE_DEFAULT_MODEL') || 'Qwen/Qwen2.5-Coder-32B-Instruct'
        @embedding_model = ENV.fetch('HUGGING_FACE_EMBEDDING_MODEL') || 'sentence-transformers/all-MiniLM-L6-v2'
      end
    end
  end
end
