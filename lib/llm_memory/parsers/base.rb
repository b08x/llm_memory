#!/usr/bin/env ruby
# frozen_string_literal: true

module LlmMemory
  module Parser
    class Base
      attr_reader :file_object

      def initialize(file_object)
        @file_object = file_object
      end

      def parse
        raise NotImplementedError, "#{self.class} must implement #parse"
      end

      protected

      def read_file
        File.read(file_object.path)
      end

      def basic_metadata
        {
          format: file_object.extension[1..],
          parser: self.class.name,
          parsed_at: Time.now.utc.iso8601,
          file_path: file_object.path.to_s,
          file_name: file_object.name,
          file_size: file_object.size
        }
      end
    end
  end
end
