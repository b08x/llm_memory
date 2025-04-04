# frozen_string_literal: true

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
        require 'hugging_face'
        @client ||= ::HuggingFace::InferenceApi.new(
          api_token: ENV.fetch('HUGGING_FACE_API_TOKEN')
        )
      end

      # Send a chat request to Hugging Face
      # @param parameters [Hash, Array] Either a hash with :messages key or an array of messages directly
      # @return [String] The generated text response
      def huggingface_chat(parameters)
        # Extract the input text from parameters
        input = if parameters.is_a?(Hash) && parameters[:messages].is_a?(Array)
                  # Handle case where parameters is a hash with :messages key
                  parameters[:messages][0][:content]
                elsif parameters.is_a?(Array)
                  # Handle case where parameters is an array of messages directly
                  parameters[0][:content]
                else
                  # Handle case where parameters might be a single message
                  parameters.is_a?(Hash) ? parameters[:content] : parameters.to_s
                end
        model = parameters[:model] || LlmMemory.configuration.huggingface_default_model

        begin
          client.text_generation(input: input, model: model)
        rescue StandardError => e
          logger.error("Huggingface API error: #{e}")
          raise e
        end
      end
    end
  end
end
