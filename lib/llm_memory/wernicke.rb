# frozen_string_literal: true

# loader
require_relative 'loader'
require_relative 'loaders/file_loader'

module LlmMemory
  # The Wernicke class provides a high-level interface for loading data using different loaders.
  #
  # It acts as a facade, simplifying the process of using various loaders
  # registered with the LoaderManager.
  #
  # @example
  #   data = LlmMemory::Wernicke.load(:file_loader, "path/to/my/file.txt")
  class Wernicke
    # Loads data using a specified loader.
    #
    # This method retrieves the appropriate loader class from the LoaderManager
    # based on the provided loader name, instantiates it, and then calls its
    # `load` method with the given arguments.
    #
    # @param loader_name [Symbol] The name of the loader to use.
    # @param args [Array] The arguments to pass to the loader's `load` method.
    # @raise [RuntimeError] if the specified loader is not found.
    # @return [Object] The data loaded by the loader.
    #
    # @example
    #   data = LlmMemory::Wernicke.load(:file_loader, "my_file.txt")
    def self.load(loader_name, *args)
      loader_class = LoaderManager.loaders[loader_name]
      raise "Loader '#{loader_name}' not found." unless loader_class

      loader_instance = loader_class.new
      loader_instance.load(*args)
    end
  end
end
