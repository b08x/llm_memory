# frozen_string_literal: true

require 'omniai/mistral'
require 'llm_memory'

module LlmMemory
  module Llms
    module Mistral
      # Returns a memoized OmniAI::Mistral client instance.
      #
      # The client is configured using values from LlmMemory.configuration.
      # It uses:
      # - api_key: taken from configuration or the MISTRAL_API_KEY environment variable.
      # - host: optional, defaults to 'https://api.mistral.ai' if not specified.
      def client
        @client ||= OmniAI::Mistral::Client.new(
          api_key: LlmMemory.configuration.mistral_api_key || ENV['MISTRAL_API_KEY'],
          host: LlmMemory.configuration.mistral_host
        )
      end

      def mistral_chat(parameters)
        model = parameters[:model] || LlmMemory.configuration.mistral_default_model
        messages = parameters[:messages]
        temperature = parameters[:temperature] || 0.7
        begin
          response = client.chat(model: model, temperature: temperature) do |prompt|
            messages.each do |msg|
              prompt.user msg[:content]
            end
          end

          response_content = response.text

          # Format the response to match the OpenAI format
          {
            'choices' => [
              {
                'message' => {
                  'role' => 'assistant',
                  'content' => response_content
                }
              }
            ]
          }
        rescue StandardError => e
          logger.error("Mistral API error: #{e.message}")
          raise e
        end
      end
    end
  end
end
