require 'openai'
require 'llm_memory'

module LlmMemory
  module Llms
    module Openai
      def client
        @client ||= OpenAI::Client.new(
          access_token: LlmMemory.configuration.openai_api_key
        )
      end
    end
  end
end
