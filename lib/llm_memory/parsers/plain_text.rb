#!/usr/bin/env ruby
# frozen_string_literal: true

module LlmMemory
  module Parser
    # Handles parsing of plain text files
    class PlainText
      EXTENSIONS = ['.txt']
      CONTENT_TYPES = ['text/plain']

      def self.parse(file_path)
        content = File.read(file_path)

        metadata = {
          'line_count' => content.lines.count,
          'char_count' => content.length
        }

        { content: content, metadata: metadata }
      end

      def self.handles?(file_path)
        EXTENSIONS.include?(File.extname(file_path).downcase) ||
          CONTENT_TYPES.include?(Marcel::MimeType.for(file_path))
      end
    end
  end
end
