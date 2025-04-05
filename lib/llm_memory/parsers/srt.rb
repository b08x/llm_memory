#!/usr/bin/env ruby
# frozen_string_literal: true

require 'srt'
require 'webvtt'

module LlmMemory
  module Parser
    # Handles parsing and conversion of subtitle files (SRT and WebVTT)
    class Subtitle
      EXTENSIONS = ['.srt', '.vtt']
      CONTENT_TYPES = ['application/x-subrip', 'text/vtt']

      attr_reader :path, :source
      attr_accessor :text

      def initialize(item)
        @item = item
        @path = Pathname.new(item.path)
        @text = ''
      end

      def parse_srt
        @srt = SRT::File.parse(File.new(@path.cleanpath.to_s))
        @srt.lines.each do |line|
          # Extract the text after the last newline
          text_part = line.text.join(' ').split("\n").last
          # Skip lines with timestamps
          next if text_part && text_part.match?(/<[^>]+>/)

          @text += "#{text_part}\n"
        end
        @text
      end

      def parse_webvtt
        @vtt = WebVTT::File.new(@path.cleanpath.to_s)
        seen_lines = []
        @vtt.cues.each do |cue|
          line = cue.text
          next if seen_lines.include?(line)

          # Extract the text after the last newline
          text_part = line.split("\n").last
          # Skip lines with timestamps
          next if text_part && text_part.match?(/<[^>]+>/)

          @text += "#{text_part}\n"
          seen_lines << line
        end
        @text
      end

      def convert_srt_to_vtt
        output_path = File.join(
          @path.dirname.to_s,
          @path.basename.to_s.gsub('srt', 'vtt')
        )

        @vtt = WebVTT.convert_from_srt(@path.cleanpath.to_s, output_path)
        puts "SRT converted to VTT - file placed in #{output_path}"
      end

      def self.handles?(file_path)
        EXTENSIONS.include?(File.extname(file_path).downcase) ||
          CONTENT_TYPES.include?(Marcel::MimeType.for(file_path))
      end
    end
  end
end
