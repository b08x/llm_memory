#!/usr/bin/env ruby
# frozen_string_literal: true

# lib/llm_memory/loader.rb
module LlmMemory
  # The Loader module provides a base interface for loader classes.
  #
  # It defines the necessary methods for registering and using loader models.
  # Loader models are used to load data from various sources.
  module Loader
    # This method is called when the module is included in a class.
    # It extends the including class with the ClassMethods module.
    #
    # @param base [Class] The class that includes this module.
    def self.included(base)
      base.extend(ClassMethods)
    end

    # The ClassMethods module provides class-level methods for loader classes.
    module ClassMethods
      # Registers a loader class with the LoaderManager.
      #
      # This allows the loader class to be used by name later.
      #
      # @param name [Symbol] The name to register the loader class under.
      #
      # @example
      #   class MyLoader
      #     include LlmMemory::Loader
      #     register_loader :my_loader
      #   end
      def register_loader(name)
        LlmMemory::LoaderManager.register_loader(name, self)
      end
    end

    # Loads data from a source.
    #
    # This method must be implemented by any class that includes the Loader module.
    # It is responsible for loading data from a specific source.
    #
    # @raise [NotImplementedError] if the method is not implemented.
    # @return [Object] The loaded data.
    #
    # @example
    #   class MyLoader
    #     include LlmMemory::Loader
    #     register_loader :my_loader
    #     def load
    #       # Implementation to load data
    #       "Loaded Data"
    #     end
    #   end
    def load
      raise NotImplementedError, "Each loader must implement the 'load' method."
    end
  end

  # The LoaderManager class manages registered loader classes.
  #
  # It provides a way to register and retrieve loader classes by name.
  class LoaderManager
    @loaders = {}

    # Registers a loader class.
    #
    # @param name [Symbol] The name to register the loader class under.
    # @param klass [Class] The loader class to register.
    def self.register_loader(name, klass)
      @loaders[name] = klass
    end

    class << self
      # @return [Hash{Symbol => Class}] A hash of registered loader classes.
      attr_reader :loaders
    end
  end
end
