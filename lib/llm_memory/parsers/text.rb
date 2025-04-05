#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'base'
require 'yaml'

module LlmMemory
  module Parser
    class Text < Base
      def parse
        content = read_file
        return ['', basic_metadata] if content.strip.empty?

        # Ensure proper encoding
        content.force_encoding('UTF-8')
        content = content.encode('UTF-8', invalid: :replace, undef: :replace)

        [
          content,
          basic_metadata.merge(
            format: 'text',
            content_type: 'text/plain',
            line_count: content.lines.count,
            size: content.bytesize
          )
        ]
      end
    end

    class MD < Base
      FRONT_MATTER_PATTERN = /\A---\n(.*?)\n---\n(.*)\z/m

      def parse
        content = read_file
        return ['', basic_metadata] if content.strip.empty?

        # Ensure proper encoding
        content.force_encoding('UTF-8')
        content = content.encode('UTF-8', invalid: :replace, undef: :replace)

        # Extract YAML front matter if present
        if content =~ FRONT_MATTER_PATTERN
          front_matter = ::Regexp.last_match(1)
          content = ::Regexp.last_match(2)
          metadata = parse_front_matter(front_matter)
        else
          metadata = {}
        end

        # Convert Markdown to plain text while preserving line breaks
        text = content.gsub(/^#+ /, '') # Remove headers
                      .gsub(/\[([^\]]+)\]\([^)]+\)/, '\1') # Convert links to text
                      .gsub(/[*_~]/, '') # Remove emphasis markers
                      .gsub(/`[^`]+`/, '') # Remove inline code
                      .gsub(/^```.*?```/m, '') # Remove code blocks
                      .gsub(/^\s*[-*+]\s+/, '') # Convert list items to plain text
                      .strip

        [
          text,
          basic_metadata.merge(
            format: 'markdown',
            content_type: 'text/markdown',
            line_count: text.lines.count,
            size: text.bytesize
          ).merge(metadata)
        ]
      end

      private

      def parse_front_matter(content)
        YAML.safe_load(content, permitted_classes: [Date, Time], symbolize_names: true)
      rescue StandardError => e
        { yaml_error: e.message }
      end
    end
  end
end
