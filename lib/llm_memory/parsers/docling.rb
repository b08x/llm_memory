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
require 'pathname' # Ensure Pathname is required

module LlmMemory
  module Parser
    class Docling
      # Use extend instead of include to make methods available at the class level
      extend PyCall::Import

      DOCLING_ARTIFACTS_PATH = ENV['DOCLING_ARTIFACTS_PATH']

      # Import all required Python modules at the class level
      # Note: Added Pathname from pathlib here for consistency, though Ruby's Pathname is used.
      pyfrom 'docling_core.types.doc', import: %i[ImageRefMode PictureItem TableItem]
      pyfrom 'docling.datamodel.base_models', import: %i[FigureElement InputFormat Table]
      pyfrom 'docling.datamodel.pipeline_options', import: %i[EasyOcrOptions PdfPipelineOptions]
      pyfrom 'docling.document_converter', import: %i[DocumentConverter PdfFormatOption]
      pyfrom 'docling.utils.export', import: :generate_multimodal_pages
      pyfrom 'docling.utils.utils', import: :create_hash
      pyfrom 'pathlib', import: :Path # Python's Path, used for calling python methods

      IMAGE_RESOLUTION_SCALE = 2.0

      attr_reader :doc_converter, :file_path, :output_dir # Added output_dir to reader

      def initialize(artifacts_path = DOCLING_ARTIFACTS_PATH, file_path: nil)
        @file_path = file_path
        # Sanatizes a filename to be used as a foldername
        # Replace spaces with underscores, remove special characters, and downcase
        file_folder = File.basename(@file_path).gsub(/\s/, '_').gsub(/[^a-zA-Z0-9_.]/, '').downcase

        # Use Ruby's Pathname for output directory management
        @output_dir = Pathname.new(ENV['DOCLING_OUTPUT']).join(file_folder)
        @artifacts_path = artifacts_path

        # Create output directory if it doesn't exist
        FileUtils.mkdir_p(@output_dir.to_s) # Use .to_s for FileUtils

        setup_converter
      end

      # Create the document converter with PDF-specific options
      def setup_converter
        # Create pipeline options with artifacts path if provided
        pipeline_options_args = {}

        # Only add artifacts_path if it's provided
        pipeline_options_args[:artifacts_path] = @artifacts_path if @artifacts_path
        pipeline_options_args[:do_ocr] = true
        pipeline_options_args[:ocr_options_use_gpu] = false
        pipeline_options_args[:do_table_structure] = true
        pipeline_options_args[:table_structure_options_do_cell_matching] = true
        # Ensure image generation flags are set
        pipeline_options_args[:generate_page_images] = true
        pipeline_options_args[:generate_picture_images] = true
        pipeline_options_args[:generate_table_images] = true # Explicitly enable table images if needed by docling
        pipeline_options_args[:images_scale] = IMAGE_RESOLUTION_SCALE

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
      def parse
        pastel = Pastel.new
        puts "\n#{pastel.bold("Processing PDF: #{File.basename(@file_path)}")}"

        # Display document information
        display_document_info(@file_path)

        # --- Conversion (Progress bar removed for clarity, add back if needed) ---
        start_time = Time.now
        # Convert using Python's Path object for the file path argument
        conv_res = @doc_converter.convert(Path.call(@file_path.to_s))
        end_time = Time.now
        elapsed_time = end_time - start_time
        puts "Conversion time: #{elapsed_time.round(2)} seconds"
        # --- End Conversion ---

        # Extract base filename (stem) for output files
        # Use Ruby's File methods on the original @file_path
        file_name = File.basename(@file_path)
        file_stem = File.basename(@file_path, '.*')

        puts "PDF #{file_name} parsed."
        puts "Saving outputs to: #{@output_dir}"

        # --- Export Text/Data Formats ---
        # Export to markdown
        md_path = @output_dir.join("#{file_stem}.md")
        File.write(md_path.to_s, conv_res.document.export_to_markdown)
        puts "Saved Markdown: #{md_path}"

        # Export to JSON
        json_path = @output_dir.join("#{file_stem}.json")
        # Convert PyCall DictProxy to Ruby Hash before generating JSON
        File.write(json_path.to_s, JSON.generate(conv_res.document.export_to_dict.to_h))
        puts "Saved JSON: #{json_path}"

        # Export to doctags
        doctags_path = @output_dir.join("#{file_stem}.doctags")
        File.write(doctags_path.to_s, conv_res.document.export_to_document_tokens)
        puts "Saved DocTags: #{doctags_path}"
        # --- End Export Text/Data Formats ---

        # --- Export Images ---
        save_page_images(conv_res, file_stem)
        save_element_images(conv_res, file_stem)
        # --- End Export Images ---

        puts "#{pastel.green('Processing complete.')}"

        # Return hash with paths
        {
          input_file: file_name,
          output_dir: @output_dir.to_s,
          markdown_path: md_path.to_s,
          json_path: json_path.to_s,
          doctags_path: doctags_path.to_s
          # Consider adding paths to saved images if needed
        }
      end

      # Extract and display document information
      def display_document_info(file_path)
        file_path_str = file_path.to_s # Ensure it's a string
        file_name = File.basename(file_path_str)
        file_ext = File.extname(file_path_str).downcase

        # Determine document type
        doc_type = 'PDF Document' # Assuming PDF for now

        # Get page count
        page_count = LlmMemory::Parser::Docling.get_page_count(file_path_str, file_ext)

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
      def self.get_page_count(file_path, file_ext)
        if file_ext == '.pdf'
          begin
            reader = PDF::Reader.new(file_path)
            reader.page_count
          rescue StandardError => e
            puts "Warning: Could not read page count from PDF: #{e.message}"
            'Unknown'
          end
        else
          'Unknown'
        end
      end

      private # Keep helper methods private

      # --- Image Saving Methods ---

      # Saves images for each page of the document.
      # @param conv_res [PyObject] The result object from doc_converter.convert
      # @param file_stem [String] The base filename without extension
      def save_page_images(conv_res, file_stem)
        puts 'Saving page images...'
        # Convert the Python dict_items object to a Ruby Array using .to_a
        # This allows us to iterate using Ruby's .each method.
        # Each item in the array will be a two-element array: [python_key, python_page_object]
        conv_res.document.pages.each_with_index do |page, page_no|
          # Convert potential PyCall integer key to Ruby integer if necessary
          # Access page_no attribute directly from the page object
          page_no = page_no.to_i # Ensure page_no is a Ruby integer

          # Construct the full path for the page image file using Pathname
          page_image_filename = @output_dir.join("#{file_stem}-page-#{page_no}.png")

          # Check if the page has an image attribute and it's not nil
          unless page.respond_to?(:image) && page.image
            puts "Warning: Page #{page_no} does not have an image attribute or image is nil."
            next # Skip to the next page
          end

          # Access the PIL image object (assuming structure like page.image.pil_image)
          # Check if pil_image exists before trying to save
          unless page.image.respond_to?(:pil_image) && page.image.pil_image
            puts "Warning: Page #{page_no} image reference does not have a pil_image attribute or it is nil."
            next # Skip to the next page
          end
          pil_image = page.image.pil_image

          # Save the image using PyCall to access the PIL save method
          begin
            # Use 'wb' mode implicitly handled by PIL's save via filename
            pil_image.save(page_image_filename.to_s, format: 'PNG')
            # puts "Saved: #{page_image_filename.basename}" # Optional: print saved filename
          rescue PyCall::PyError => e
            puts "Error saving page #{page_no} image: #{e.message}"
            puts "Python Exception Type: #{e.type}"
            puts "Python Exception Value: #{e.value}"
            # Optionally print traceback: puts e.traceback.format if e.traceback
          end
        end
        puts 'Finished saving page images.'
      end

      # Saves images for specific elements like Tables and Pictures.
      # @param conv_res [PyObject] The result object from doc_converter.convert
      # @param file_stem [String] The base filename without extension
      def save_element_images(conv_res, file_stem)
        puts 'Saving element images (tables, pictures)...'
        table_counter = 0
        picture_counter = 0
        items = PyCall::List.new(conv_res.document.iterate_items) # Convert generator to a list
        # Iterate through each element in the document.
        # Assuming iterate_items yields [element, level] pairs.
        # Convert the Python iterator to a Ruby Array first
        items.each do |element|
          element_image = nil
          element_type = nil
          counter = nil
          filename_prefix = nil

          # Check if the element is a TableItem (using the imported Python class)
          if element.is_a?(TableItem)
            table_counter += 1
            element_type = 'table'
            counter = table_counter
            filename_prefix = "#{file_stem}-#{element_type}-#{counter}"
            # Check if the element responds to get_image before calling it
            element_image = element.get_image(conv_res.document) if element.respond_to?(:get_image)

          # Check if the element is a PictureItem (using the imported Python class)
          elsif element.is_a?(PictureItem)
            picture_counter += 1
            element_type = 'picture'
            counter = picture_counter
            filename_prefix = "#{file_stem}-#{element_type}-#{counter}"
            # Check if the element responds to get_image before calling it
            element_image = element.get_image(conv_res.document) if element.respond_to?(:get_image)
          end

          # If it's a recognized element type and has an image, save it
          if element_image && filename_prefix
            element_image_filename = @output_dir.join("#{filename_prefix}.png")
            begin
              # Assuming get_image returns a PIL image object directly
              # Check if the returned object has a 'save' method
              unless element_image.respond_to?(:save)
                puts "Error: The object returned by get_image for #{element_type} #{counter} does not have a 'save' method."
                next # Skip this element
              end
              element_image.save(element_image_filename.to_s, format: 'PNG')
              # puts "Saved: #{element_image_filename.basename}" # Optional: print saved filename
            rescue PyCall::PyError => e
              puts "Error saving #{element_type} #{counter} image: #{e.message}"
              puts "Python Exception Type: #{e.type}"
              puts "Python Exception Value: #{e.value}"
              # Removed the NoMethodError catch here as we check with respond_to? now
            end
          elsif element_type && !element_image
            # Refined warning message
            if element.respond_to?(:get_image)
              puts "Warning: #{element_type.capitalize} #{counter} found, but get_image returned nil."
            else
              puts "Warning: #{element_type.capitalize} #{counter} found, but it does not respond to get_image method."
            end
          end
        end
        puts 'Finished saving element images.'
      end
      # --- End Image Saving Methods ---
    end
  end
end
