# frozen_string_literal: true

require 'omniai/google'
require 'llm_memory'

module LlmMemory
  module Llms
    # The Gemini module provides functionality for interacting with Google's Gemini AI models.
    # It handles authentication and communication with the Gemini API.
    module Gemini
      # Returns a client for the Gemini API.
      #
      # @return [OmniAI::Google::Client] A client for the Gemini API.
      def client
        @client ||= begin
          api_key = LlmMemory.configuration.gemini_api_key || ENV.fetch('GEMINI_API_KEY')
          OmniAI::Google::Client.new(api_key: api_key)
        end
      end

      # Formats messages for the Gemini API using omniai-google format.
      #
      # @param messages [Array<Hash>] An array of message hashes with 'role' and 'content' keys.
      # @return [Array<Hash>] An array of messages formatted for the omniai-google API.
      def format_messages_for_gemini(messages)
        formatted_messages = []

        messages.each do |msg|
          case msg[:role]
          when 'system'
            formatted_messages << { role: 'system', content: msg[:content] }
          when 'user'
            formatted_messages << { role: 'user', content: msg[:content] }
          when 'assistant'
            formatted_messages << { role: 'assistant', content: msg[:content] }
          end
        end

        formatted_messages
      end

      # Sends a chat request to the Gemini API using omniai-google.
      #
      # @param parameters [Hash] Parameters for the chat request.
      # @return [Hash] The response from the Gemini API formatted to match OpenAI's format.
      def gemini_chat(parameters)
        model = parameters[:model]
        messages = format_messages_for_gemini(parameters[:messages])
        temperature = parameters[:temperature] || 0.7

        begin
          response = client.chat(model: model, temperature: temperature) do |prompt|
            messages.each do |msg|
              case msg[:role]
              when 'system'
                prompt.system msg[:content]
              when 'user'
                prompt.user msg[:content]
              when 'assistant'
                prompt.assistant msg[:content]
              end
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
          logger.error("Gemini API error: #{e.message}")
          raise e
        end
      end
    end
  end
end
