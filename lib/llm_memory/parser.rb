# frozen_string_literal: true

GRAMMAR_DIR = File.join(File.expand_path(__dir__), 'parsers', 'grammars')

require_relative 'parsers/treetop_grammar'
require_relative 'parsers/markdown'
require_relative 'parsers/json'
require_relative 'parsers/plain_text'
require_relative 'parsers/docling'

# Shale allows converting collections for formats that support it (JSON, YAML and CSV).
# https://github.com/kgiszczak/shale

module Parsers
  # Factory for creating appropriate parser instances
  class ParserFactory
    PARSER_CLASSES = [
      LlmMemory::Parser::Docling,
      LlmMemory::Parser::Markdown,
      LlmMemory::Parser::PlainText # Must be last as it's the fallback
    ].freeze

    def self.get_parser(file_path)
      PARSER_CLASSES.find { |parser_class| parser_class.handles?(file_path) }
    end
  end
end
