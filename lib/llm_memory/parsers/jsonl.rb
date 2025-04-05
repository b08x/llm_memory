#!/usr/bin/env ruby
# frozen_string_literal: true

module LlmMemory
  module Parser
    # Handles parsing of JSONL (JSON Lines) format files
    class JSONL
      EXTENSIONS = ['.jsonl']
      CONTENT_TYPES = ['application/x-jsonlines', 'application/jsonl']

      def self.parse(file)
        File.open(file, 'r') do |f|
          f.each_line do |line|
            extracted_data = extract_data(line)
            yield extracted_data if block_given?
          end
        end
      end

      def self.extract_data(jsonl_entry)
        data = JSON.parse(jsonl_entry)
        {
          'name' => data['name'],
          'send_date' => data['send_date'],
          'mes' => data['mes']
        }
      end

      def self.handles?(file_path)
        EXTENSIONS.include?(File.extname(file_path).downcase) ||
          CONTENT_TYPES.include?(Marcel::MimeType.for(file_path))
      end
    end
  end
end
