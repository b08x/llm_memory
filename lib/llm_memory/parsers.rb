# frozen_string_literal: true

GRAMMAR_DIR = File.join(File.expand_path(__dir__), 'parsers', 'grammars')

require 'treetop'
require_relative 'parsers/treetop_grammar'
require_relative 'parsers/markdown'
# require_relative 'parsers/json'
# require_relative 'parsers/jsonl'
require_relative 'parsers/plain_text'
require_relative 'parsers/srt'
require_relative 'parsers/docling'

require_relative 'parsers/base'
require_relative 'parsers/structured'
require_relative 'parsers/text'
