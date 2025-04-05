# frozen_string_literal: true

require 'find'
require_relative '../loader'
require_relative '../fileobject'

module LlmMemory
  class FileLoader
    include Loader

    register_loader :file

    def load(directory_path)
      Find.find(directory_path) do |file_path|
        next if File.directory?(file_path)

        @file_object = LlmMemory::FileObject.new(file_path)

        next unless @file_object.processable?

        parser = create_parser
        next if parser.nil?

        content, metadata = parser.parse
        p content
        p metadata
        puts "\n"

        # content = Lingua::EN::Readability.new(content)

        # puts content.num_paragraphs

        # files_array << {
        #   content: content.text,
        #   metadata: {
        #     file_name: @file_object.name,
        #     timestamp: ctime.strftime('%Y%m%d%H%M%S') # YYMMDDHHmmss
        #   }
        # }
      end

      # files_array
    end

    def create_parser
      case @file_object.extension
      when '.txt'
        Parser::Text.new(@file_object)
      when '.md', '.markdown'
        Parser::Markdown.new(@file_object.path)
      when '.pdf'
        pages = Parser::Docling.get_page_count(@file_object.path, @file_object.extension)
        return if pages > 10

        Parser::Docling.new(file_path: @file_object.path)
      when '.json', '.jsonl'
        Parser::Json.new(@file_object)
      when '.csv'
        Parser::Csv.new(@file_object)
      when '.srt', '.vtt'
        Parser::Subtitle.new(@file_object)
      else
        Parsers::Text.new(@file_object)
      end
    end
  end
end
