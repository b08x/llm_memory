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
      # @return [HuggingFace::InferenceApi] The Hugging Face Inference API client.
      # @raise [ArgumentError] if the api_token is nil or empty.
      def client
        require 'hugging_face'
        @client ||= ::HuggingFace::InferenceApi.new(
          api_token: ENV.fetch('HUGGING_FACE_API_TOKEN')
        )
      end

      # Send a chat request to Hugging Face
      # @param parameters [Hash, Array, String] Either a hash with :messages key, an array of messages directly, or a string
      # @option parameters [String] :model The model to use for the chat.
      # @option parameters [Array<Hash>] :messages An array of message hashes with 'role' and 'content' keys.
      # @option parameters [String] :content The content of the message.
      # @return [String] The generated text response
      # @raise [StandardError] if there is an error with the Hugging Face API.
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
