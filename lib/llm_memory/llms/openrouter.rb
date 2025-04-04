# frozen_string_literal: true

require 'openai'
require 'llm_memory'

module LlmMemory
  module Llms
    module OpenRouter
      def client
        @client ||= OpenAI::Client.new(
          access_token: ENV.fetch('OPENAI_ACCESS_TOKEN'),
          uri_base: 'https://openrouter.ai/api/v1'
        )
      end
    end
  end
end
