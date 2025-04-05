# frozen_string_literal: true

require 'digest'
require 'mime/types/columnar'
require 'pathname'
require 'mimemagic'

module LlmMemory
  # The FileObject class handles gathering and validating file attributes, and determining
  # file types. It serves as a foundational class that provides clean file metadata to
  # the Document Ohm model.
  class FileObject
    # Custom error class for FileObject-specific errors
    class Error < StandardError; end

    # Supported file types and their extensions
    FILE_TYPES = {
      text: %w[.txt .md .markdown .org],
      # structured_text: %w[.json .jsonl .csv],
      document: %w[.pdf]
      # document: %w[.pdf .doc .docx .rtf],
      # audio: %w[.mp3 .wav .ogg .flac .opus .m4a .aiff],
      # video: %w[.mp4 .avi .mov .mkv .webm],
      # image: %w[.jpg .jpeg .png .gif .svg]
    }.freeze

    # File attributes
    attr_reader :name, :path, :extension, :type, :size, :mtime, :ctime, :mime_type, :checksum

    # Initializes a new FileObject instance
    #
    # @param file_path [String, Pathname] Path to the file
    # @raise [FileObject::Error] If file_path is invalid or file doesn't exist
    def initialize(file_path)
      @path = validate_and_normalize_path(file_path)
      @name = @path.basename.to_s
      @extension = @path.extname.downcase
      @type = determine_file_type
      @checksum = calculate_checksum
      @mime_type = determine_mime_type
      @size, @mtime, @ctime = gather_file_stats
    rescue StandardError => e
      raise Error, "Failed to initialize FileObject: #{e.message}"
    end

    # Determines if file is processable by the system
    #
    # @return [Boolean] True if file type is supported
    def processable?
      FILE_TYPES.key?(@type)
    end

    # Returns hash of file attributes for Document model creation
    #
    # @return [Hash] File attributes
    def attributes
      {
        name: @name,
        path: @path.to_s,
        extension: @extension,
        type: @type,
        size: @size,
        mtime: @mtime.to_i,
        ctime: @ctime.to_i,
        mime: @mime_type,
        checksum: @checksum,
        content: '',
        metadata: {}
      }
    end

    # Returns a string representation of the FileObject
    #
    # @return [String] String representation
    def to_s
      "#{@name} (#{@type})"
    end

    # Returns a detailed inspection of the FileObject
    #
    # @return [String] Detailed string representation
    def inspect
      "#<FileObject name=#{@name} type=#{@type} size=#{format_size(@size)}>"
    end

    private

    def validate_and_normalize_path(file_path)
      path = file_path.is_a?(Pathname) ? file_path : Pathname.new(file_path)
      raise Error, "File not found: #{path}" unless path.exist?
      raise Error, "Not a file: #{path}" unless path.file?
      raise Error, "File not readable: #{path}" unless path.readable?

      path.realpath
    end

    def calculate_checksum
      Digest::MD5.file(@path).hexdigest
    rescue StandardError => e
      raise Error, "Failed to calculate checksum: #{e.message}"
    end

    def determine_file_type
      FILE_TYPES.find { |_type, extensions| extensions.include?(@extension) }&.first || :unknown
    end

    def determine_mime_type
      MimeMagic.by_path(@path.to_s)&.type || 'application/octet-stream'
    end

    def gather_file_stats
      stat = @path.stat
      [stat.size, stat.mtime, stat.ctime]
    rescue StandardError => e
      raise Error, "Failed to gather file stats: #{e.message}"
    end

    def format_size(bytes)
      return '0B' if bytes.zero?

      units = %w[B KB MB GB TB]
      exp = (Math.log(bytes) / Math.log(1024)).to_i
      exp = units.length - 1 if exp > units.length - 1
      format('%.1f %s', bytes.to_f / (1024**exp), units[exp])
    end
  end
end
