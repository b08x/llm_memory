#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'base'

module LlmMemory
  module Parser
    class Subtitle < Base
      def parse
        content = read_file
        return ['', basic_metadata] if content.strip.empty?

        # Ensure proper encoding
        content.force_encoding('UTF-8')
        content = content.encode('UTF-8', invalid: :replace, undef: :replace)

        # Remove WebVTT header if present
        content = content.sub(/^WEBVTT\n\n/, '')

        # Parse subtitles
        subtitles = parse_subtitles(content)

        # Extract text content preserving line breaks
        text_content = subtitles.map { |sub| sub[:text] }.join("\n\n")

        [
          text_content,
          basic_metadata.merge(
            format: file_object.extension[1..],
            content_type: 'text/plain',
            timing_data: subtitles,
            line_count: text_content.lines.count,
            size: text_content.bytesize
          )
        ]
      end

      private

      def parse_subtitles(content)
        case file_object.extension
        when '.srt'
          parse_srt(content)
        when '.vtt'
          parse_vtt(content)
        else
          []
        end
      end

      def parse_srt(content)
        subtitles = []
        current_subtitle = {}

        content.split(/\n\n+/).each do |block|
          lines = block.strip.split("\n")
          next if lines.empty?

          # Parse timecode line (format: 00:00:00,000 --> 00:00:00,000)
          next unless lines[1] && lines[1].include?('-->')

          start_time, end_time = lines[1].split('-->').map(&:strip)

          current_subtitle = {
            index: lines[0].to_i,
            start_time: parse_srt_time(start_time),
            end_time: parse_srt_time(end_time),
            text: lines[2..].join("\n").strip,
            speaker: extract_speaker(lines[2..].join("\n"))
          }

          subtitles << current_subtitle
        end

        subtitles
      end

      def parse_vtt(content)
        subtitles = []
        current_subtitle = {}
        in_subtitle = false

        content.split("\n").each do |line|
          line.strip!
          next if line.empty?

          # Parse timecode line (format: 00:00:00.000 --> 00:00:00.000)
          if line.include?('-->')
            start_time, end_time = line.split('-->').map(&:strip)

            current_subtitle = {
              start_time: parse_vtt_time(start_time),
              end_time: parse_vtt_time(end_time),
              text: '',
              speaker: nil
            }

            in_subtitle = true
          elsif in_subtitle
            if line.empty?
              unless current_subtitle[:text].empty?
                current_subtitle[:speaker] = extract_speaker(current_subtitle[:text])
                subtitles << current_subtitle
              end
              in_subtitle = false
            else
              # Handle WebVTT voice tags
              line = line.gsub(/<v\s+([^>]+)>/, '') # Remove voice tags but keep speaker
              current_subtitle[:text] += "\n" unless current_subtitle[:text].empty?
              current_subtitle[:text] += line.strip
            end
          end
        end

        # Add the last subtitle if there is one
        if in_subtitle && !current_subtitle[:text].empty?
          current_subtitle[:speaker] = extract_speaker(current_subtitle[:text])
          subtitles << current_subtitle
        end

        subtitles
      end

      def parse_srt_time(time_str)
        hours, minutes, seconds_ms = time_str.split(':')
        seconds, milliseconds = seconds_ms.split(',')

        (hours.to_i * 3600) + (minutes.to_i * 60) + seconds.to_i + (milliseconds.to_i / 1000.0)
      end

      def parse_vtt_time(time_str)
        hours, minutes, seconds_ms = time_str.split(':')
        seconds, milliseconds = seconds_ms.split('.')

        (hours.to_i * 3600) + (minutes.to_i * 60) + seconds.to_i + (milliseconds.to_i / 1000.0)
      end

      def extract_speaker(text)
        # Try to extract speaker from common formats:
        # "Speaker: Text"
        # "[Speaker] Text"
        # "<v Speaker>Text"
        if text =~ /^([^:]+):\s*/
          ::Regexp.last_match(1).strip
        elsif text =~ /^\[([^\]]+)\]\s*/
          ::Regexp.last_match(1).strip
        elsif text =~ /<v\s+([^>]+)>/
          ::Regexp.last_match(1).strip
        end
      end
    end
  end
end
