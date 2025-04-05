# frozen_string_literal: true

require 'find'
require_relative '../loader'
require_relative '../fileobject'

module LlmMemory
  class FileLoader
    include Loader

    register_loader :file

    def load(directory_path)
      files_array = []
      Find.find(directory_path) do |file_path|
        next if File.directory?(file_path)

        @file_object = LlmMemory::FileObject.new(file_path)

        next unless @file_object.processable?

        parser = create_parser
        parser.parse

        content = Lingua::EN::Readability.new(content)

        files_array << {
          content: content.text,
          metadata: {
            file_name: @file_object.name,
            timestamp: ctime.strftime('%Y%m%d%H%M%S') # YYMMDDHHmmss
          }
        }
      end

      files_array
    end

    def create_parser
      case @file_object.extension
      when '.txt'
        Parsers::Text.new(@file_object)
      when '.md', '.markdown'
        Parsers::Markdown.new(@file_object)
      when '.pdf'
        Parsers::Docling.new(@file_object.path)
      when '.json', '.jsonl'
        Parsers::Json.new(@file_object)
      when '.csv'
        Parsers::Csv.new(@file_object)
      when '.srt', '.vtt'
        Parsers::Subtitle.new(@file_object)
      else
        Parsers::Text.new(@file_object)
      end
    end
  end
end
