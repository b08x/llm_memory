# frozen_string_literal: true

require 'openai'
require 'llm_memory'

module LlmMemory
  module Llms
    module OpenRouter
      def client
        @client ||= OpenAI::Client.new(
          access_token: LlmMemory.configuration.openrouter_api_key,
          base_url: LlmMemory.configuration.openrouter_host
        )
      end
    end
  end
end
