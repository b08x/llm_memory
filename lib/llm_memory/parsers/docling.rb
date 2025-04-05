# frozen_string_literal: true

require 'pycall/import'
require 'fileutils'
require 'json'
require 'yaml'
require 'tty-progressbar'
require 'tty-table'
require 'pastel'
require 'mimemagic'
require 'pdf-reader'

module LlmMemory
  module Parser
    class Docling
      # Use extend instead of include to make methods available at the class level
      extend PyCall::Import

      # Import all required Python modules at the class level
      pyfrom 'docling.datamodel.base_models', import: :InputFormat
      pyfrom 'docling_core.types.doc', import: :ImageRefMode
      pyfrom 'docling.datamodel.pipeline_options', import: %i[EasyOcrOptions PdfPipelineOptions]
      pyfrom 'docling.document_converter', import: %i[DocumentConverter PdfFormatOption]
      pyfrom 'pathlib', import: :Path

      attr_reader :doc_converter

      def initialize(artifacts_path = DOCLING_ARTIFACTS_PATH, file_path: nil)
        @file_path = file_path
        # Sanatizes a filename to be used as a foldername
        # Replace spaces with underscores, remove special characters, and downcase

        file_folder = File.basename(file_path).gsub(/\s/, '_').gsub(/[^a-zA-Z0-9_.]/, '').downcase

        @output_dir = File.join(ENV['DOCLING_OUTPUT'], file_folder)
        @artifacts_path = artifacts_path

        # Create output directory if it doesn't exist
        FileUtils.mkdir_p(@output_dir)

        setup_converter
      end

      # Create the document converter with PDF-specific options
      def setup_converter
        # Create pipeline options with artifacts path if provided
        pipeline_options_args = {}

        # Only add artifacts_path if it's provided
        pipeline_options_args[:artifacts_path] = @artifacts_path if @artifacts_path
        pipeline_options_args[:generate_page_images] = true
        pipeline_options_args[:generate_picture_images] = true

        pipeline_options = PdfPipelineOptions.call(**pipeline_options_args)

        # Create format options with pipeline options for PDF
        format_options = {
          InputFormat.PDF => PdfFormatOption.call(
            pipeline_options: pipeline_options
          )
        }

        # Create document converter with format options
        @doc_converter = DocumentConverter.call(
          format_options: format_options
        )
      end

      # Parse a single PDF file with progress bar
      def parse(file_path)
        # Display document information
        display_document_info(file_path)

        # Create a progress bar
        pastel = Pastel.new
        progress_bar = TTY::ProgressBar.new(
          "[:bar] :percent :elapsed :eta #{pastel.cyan(File.basename(file_path.to_s))}",
          total: 100,
          width: 40,
          complete: '=',
          incomplete: ' '
        )

        # Start the progress bar
        progress_bar.start

        # Create a wrapper for the document converter that updates progress
        original_convert = @doc_converter.method(:convert)

        # Use a thread to simulate progress updates
        # In a real implementation, we would hook into the docling library's progress events
        progress_thread = Thread.new do
          # Simulate progress updates
          10.times do |_i|
            sleep 0.2 # Simulate processing time
            progress_bar.advance(10)
          end
        end

        # Perform the actual conversion
        result = original_convert.call(file_path)

        # Wait for progress thread to complete
        progress_thread.join

        # Ensure progress bar is complete
        progress_bar.finish

        result
      end

      # Process a PDF file and save results in multiple formats
      def process_pdf(file_path)
        pastel = Pastel.new

        puts "\n#{pastel.bold("Processing PDF: #{File.basename(file_path)}")}"

        # Convert with progress bar (which also displays document info)
        res = parse(file_path)

        file_name = res.input.file.name
        file_stem = res.input.file.stem

        puts "PDF #{file_name} parsed."
        puts "Saved outputs to: #{@output_dir}"

        # Export to markdown
        md_path = File.join(@output_dir, "#{file_stem}.md")
        File.write(md_path, res.document.export_to_markdown)

        # Export to JSON
        json_path = File.join(@output_dir, "#{file_stem}.json")
        File.write(json_path, JSON.pretty_generate(res.document.export_to_dict.to_h))

        # Export to doctags
        doctags_path = File.join(@output_dir, "#{file_stem}.doctags")
        File.write(doctags_path, res.document.export_to_document_tokens)

        {
          input_file: file_name,
          markdown_path: md_path,
          json_path: json_path,
          doctags_path: doctags_path
        }
      end

      # Extract and display document information
      def display_document_info(file_path)
        file_path = file_path.to_s if file_path.respond_to?(:to_s)
        file_name = File.basename(file_path)
        file_ext = File.extname(file_path).downcase

        # Determine document type
        doc_type = 'PDF Document'

        # Get page count
        page_count = get_page_count(file_path, file_ext)

        # Create and display table
        pastel = Pastel.new
        table = TTY::Table.new(
          [
            [pastel.cyan('Filename'), pastel.yellow(file_name)],
            [pastel.cyan('Document Type'), pastel.yellow(doc_type)],
            [pastel.cyan('Page Count'), pastel.yellow(page_count.to_s)]
          ]
        )

        puts "\n#{pastel.bold('Document Information:')}"
        puts table.render(:unicode, padding: [0, 1])
        puts
      end

      # Get page count for PDF files
      def get_page_count(file_path, file_ext)
        if file_ext == '.pdf'
          # Use pdf-reader to get PDF page count
          begin
            reader = PDF::Reader.new(file_path)
            reader.page_count
          rescue StandardError
            'Unknown'
          end
        else
          'Unknown'
        end
      end
    end
  end
end
