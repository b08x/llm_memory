#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'base'

module LlmMemory
  module Parser
    class Json < Base
      def parse
        content = read_file
        return ['', basic_metadata] if content.strip.empty?

        if file_object.extension == '.jsonl'
          parse_jsonl(content)
        else
          parse_json(content)
        end
      end

      private

      def parse_json(content)
        parsed = JSON.parse(content)
        [
          content,
          basic_metadata.merge(
            format: 'json',
            content_type: 'application/json',
            structure: parsed.class.name
          )
        ]
      rescue JSON::ParserError => e
        [
          '',
          basic_metadata.merge(
            format: 'json',
            content_type: 'application/json',
            error: e.message
          )
        ]
      end

      def parse_jsonl(content)
        # Handle empty file
        return ['', basic_metadata.merge(format: 'jsonl')] if content.strip.empty?

        # Validate each line is valid JSON
        valid = content.each_line.all? do |line|
          JSON.parse(line.strip) unless line.strip.empty?
          true
        rescue JSON::ParserError
          false
        end

        if valid
          [
            content,
            basic_metadata.merge(
              format: 'jsonl',
              content_type: 'application/x-jsonlines',
              line_count: content.lines.count
            )
          ]
        else
          [
            '',
            basic_metadata.merge(
              format: 'jsonl',
              content_type: 'application/x-jsonlines',
              error: 'Invalid JSONL format'
            )
          ]
        end
      end
    end

    class Csv < Base
      def parse
        content = read_file
        return ['', basic_metadata] if content.strip.empty?

        csv = CSV.parse(content, headers: true)
        [
          content,
          basic_metadata.merge(
            format: 'csv',
            content_type: 'text/csv',
            headers: csv.headers,
            row_count: csv.count
          )
        ]
      rescue CSV::MalformedCSVError => e
        [
          '',
          basic_metadata.merge(
            format: 'csv',
            content_type: 'text/csv',
            error: e.message
          )
        ]
      end
    end
  end
end
