#!/usr/bin/env ruby
# frozen_string_literal: true

require 'omniai/google'
require 'llm_memory'

module LlmMemory
  module Llms
    # The Gemini module provides a client for interacting with the Gemini API.
    module Gemini
      # Returns a memoized OmniAI::Google client instance.
      #
      # The client is configured using values from LlmMemory.configuration.
      # It uses:
      # - api_key: taken from configuration or the GEMINI_API_KEY environment variable.
      #
      # @return [OmniAI::Google::Client] The Gemini client instance.
      #
      # @example
      #   client = LlmMemory::Llms::Gemini.client
      #   # Use the client to interact with the Gemini API
      def client
        @client ||= OmniAI::Google::Client.new(
          api_key: LlmMemory.configuration.gemini_api_key || ENV.fetch('GEMINI_API_KEY')
        )
      end
    end
  end
end
