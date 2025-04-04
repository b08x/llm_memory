# frozen_string_literal: true

require 'openai'
require 'llm_memory'

module LlmMemory
  module Llms
    module OpenRouter
      # Returns a memoized OpenRouter client instance.
      #
      # The client is configured using the OPENAI_ACCESS_TOKEN environment variable and the OpenRouter API base URI.
      #
      # @return [OpenAI::Client] The OpenRouter API client.
      # @raise [KeyError] if the OPENAI_ACCESS_TOKEN environment variable is not set.
      def client
        @client ||= OpenAI::Client.new(
          access_token: ENV.fetch('OPENAI_ACCESS_TOKEN'),
          uri_base: 'https://openrouter.ai/api/v1'
        )
      end
    end
  end
end
