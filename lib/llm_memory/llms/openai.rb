# frozen_string_literal: true

require 'openai'
require 'llm_memory'

module LlmMemory
  module Llms
    module Openai
      # Returns a memoized OpenAI client instance.
      #
      # The client is configured using the OPENAI_ACCESS_TOKEN environment variable.
      #
      # @return [OpenAI::Client] The OpenAI API client.
      # @raise [KeyError] if the OPENAI_ACCESS_TOKEN environment variable is not set.
      def client
        @client ||= OpenAI::Client.new(
          access_token: ENV.fetch('OPENAI_ACCESS_TOKEN')
        )
      end
    end
  end
end
