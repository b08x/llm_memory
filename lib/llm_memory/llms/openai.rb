# frozen_string_literal: true

require 'openai'
require 'llm_memory'

module LlmMemory
  module Llms
    module Openai
      def client
        @client ||= OpenAI::Client.new(
          access_token: ENV.fetch('OPENAI_ACCESS_TOKEN')
        )
      end
    end
  end
end
