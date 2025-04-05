#!/usr/bin/env ruby
# frozen_string_literal: true

require 'kramdown'
require 'redcarpet'
require 'redcarpet/render_strip'

module LlmMemory
  module Parser
    # Handles parsing of markdown files with optional YAML frontmatter
    # Returns a structured hash containing both content and metadata
    # that can be directly used with TextObject model
    class Markdown
      attr_reader :path
      attr_accessor :text, :content, :metadata

      EXTENSIONS = ['.markdown', '.md'].freeze
      CONTENT_TYPES = ['text/markdown'].freeze

      def initialize(path)
        @path = path
        @text = ''
      end

      # Extracts content and metadata from markdown file
      # @return [Hash] A hash containing :content and :metadata keys
      #   compatible with TextObject model attributes
      def parse
        html = Kramdown::Document.new(File.read(@path)).to_html
        text = html.gsub(/<[^>]*>/, '')
        result = process(text)

        # Structure the result to match TextObject model attributes
        {
          content: result[:content].to_s.strip,
          metadata: prepare_metadata(result[:metadata])
        }
      rescue StandardError => e
        {
          content: '',
          metadata: prepare_metadata({ error: e.message })
        }
      end

      private

      # Processes markdown text and extracts YAML frontmatter if present
      # @param text [String] The markdown text to process
      # @return [Hash] Hash containing :content and :metadata
      def process(text)
        grammar_processor = LlmMemory::TreetopGrammar.new('markdown_yaml')
        parse_result = grammar_processor.parse(text)

        if parse_result
          metadata = extract_metadata(parse_result[:yaml_front_matter])
          {
            content: parse_result[:markdown_content],
            metadata: metadata
          }
        else
          {
            content: text,
            metadata: {}
          }
        end
      end

      # Prepares metadata hash with required fields for TextObject model
      # @param metadata [Hash] Raw metadata from parsing
      # @return [Hash] Processed metadata with required fields
      def prepare_metadata(metadata)
        {
          format: 'markdown',
          parser: 'LlmMemory::Parser::Markdown',
          parsed_at: Time.now.utc.iso8601,
          file_path: @path,
          file_name: File.basename(@path),
          file_size: File.size(@path),
          content_type: 'text/markdown'
        }.merge(metadata || {})
      end

      # Extracts and parses YAML frontmatter
      # @param yaml_front_matter [String] YAML frontmatter to parse
      # @return [Hash] Parsed YAML as hash, or empty hash if invalid
      def extract_metadata(yaml_front_matter)
        return {} if yaml_front_matter.to_s.empty?

        YAML.safe_load(yaml_front_matter)
      rescue StandardError => e
        { yaml_error: e.message }
      end

      # Checks if this parser can handle the given file
      # @param file_path [String] Path to the file
      # @return [Boolean] True if file can be handled
      def self.handles?(file_path)
        EXTENSIONS.include?(File.extname(file_path).downcase) ||
          CONTENT_TYPES.include?(Marcel::MimeType.for(file_path))
      end
    end
  end
end
