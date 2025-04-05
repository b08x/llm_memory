#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'yajl'

module LlmMemory
  module Parser
    class JSON
      def self.parse(file_path)
        json = File.new(file_path, 'r')
        parser = Yajl::Parser.new(symbolize_keys: true)
        parser.parse(json)
      end
    end
  end
end
