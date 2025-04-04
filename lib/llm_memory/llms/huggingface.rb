# frozen_string_literal: true

require 'hugging_face'
require 'llm_memory'

module LlmMemory
  module Llms
    # Client for interacting with the Hugging Face Inference API.
    #
    # This class provides a simple interface for making requests to the
    # Hugging Face Inference API. It handles the initialization of the
    # underlying HuggingFace::InferenceApi client.
    module HuggingFace
      # Initializes a new HuggingFaceClient.
      #
      # @param api_token [String] The Hugging Face API token. Defaults to the
      #   value of the `HUGGING_FACE_API_TOKEN` environment variable.
      # @raise [ArgumentError] if the api_token is nil or empty.
      def client
        @client ||= HuggingFace::InferenceApi.new(
          api_token: ENV.fetch('HUGGING_FACE_API_TOKEN')
        )
      end

      def huggingface_chat(parameters)
        model = parameters[:model]
        input = parameters[:messages][0][:content]

        begin
          response = client.text_generation(input, model: model)
        rescue StandardError => e
          LlmMemory.logger.error("Gemini API error: #{e.message}")
          raise e
        end
        

    end
  end
end
