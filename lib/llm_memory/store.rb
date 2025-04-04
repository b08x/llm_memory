# frozen_string_literal: true

# lib/llm_memory/store.rb
module LlmMemory
  # The Store module provides a base interface for store classes.
  #
  # It defines the necessary methods for registering and using store models.
  # Store models are used to manage and interact with data indexes.
  module Store
    # This method is called when the module is included in a class.
    # It extends the including class with the ClassMethods module.
    #
    # @param base [Class] The class that includes this module.
    def self.included(base)
      base.extend(ClassMethods)
    end

    # The ClassMethods module provides class-level methods for store classes.
    module ClassMethods
      # Registers a store class with the StoreManager.
      #
      # This allows the store class to be used by name later.
      #
      # @param name [Symbol] The name to register the store class under.
      # @param klass [Class] The store class to register.
      #
      # @example
      #   class MyStore
      #     include LlmMemory::Store
      #     register_store :my_store
      #   end
      def register_store(name)
        LlmMemory::StoreManager.register_store(name, self)
      end
    end

    # Creates an index in the store.
    #
    # This method must be implemented by any class that includes the Store module.
    # It is responsible for creating a new index.
    #
    # @raise [NotImplementedError] if the method is not implemented.
    # @return [void]
    #
    # @example
    #   class MyStore
    #     include LlmMemory::Store
    #     register_store :my_store
    #     def create_index
    #       # Implementation to create an index
    #     end
    #   end
    def create_index
      raise NotImplementedError, "Each store must implement the 'create_index' method."
    end

    # Checks if an index exists in the store.
    #
    # This method must be implemented by any class that includes the Store module.
    # It is responsible for checking if an index exists.
    #
    # @raise [NotImplementedError] if the method is not implemented.
    # @return [Boolean] True if the index exists, false otherwise.
    #
    # @example
    #   class MyStore
    #     include LlmMemory::Store
    #     register_store :my_store
    #     def index_exists?
    #       # Implementation to check if an index exists
    #       true
    #     end
    #   end
    def index_exists?
      raise NotImplementedError, "Each store must implement the 'index_exists?' method."
    end

    # Drops an index from the store.
    #
    # This method must be implemented by any class that includes the Store module.
    # It is responsible for deleting an existing index.
    #
    # @raise [NotImplementedError] if the method is not implemented.
    # @return [void]
    #
    # @example
    #   class MyStore
    #     include LlmMemory::Store
    #     register_store :my_store
    #     def drop_index
    #       # Implementation to drop an index
    #     end
    #   end
    def drop_index
      raise NotImplementedError, "Each store must implement the 'drop_index' method."
    end

    # Adds data to the store.
    #
    # This method must be implemented by any class that includes the Store module.
    # It is responsible for adding data to the store.
    #
    # @raise [NotImplementedError] if the method is not implemented.
    # @return [void]
    #
    # @example
    #   class MyStore
    #     include LlmMemory::Store
    #     register_store :my_store
    #     def add
    #       # Implementation to add data
    #     end
    #   end
    def add
      raise NotImplementedError, "Each store must implement the 'add' method."
    end

    # Lists data from the store.
    #
    # This method must be implemented by any class that includes the Store module.
    # It is responsible for listing data from the store.
    #
    # @raise [NotImplementedError] if the method is not implemented.
    # @return [Object] The listed data.
    #
    # @example
    #   class MyStore
    #     include LlmMemory::Store
    #     register_store :my_store
    #     def list
    #       # Implementation to list data
    #       ["data1", "data2"]
    #     end
    #   end
    def list
      raise NotImplementedError, "Each store must implement the 'list' method."
    end

    # Deletes data from the store.
    #
    # This method must be implemented by any class that includes the Store module.
    # It is responsible for deleting data from the store.
    #
    # @raise [NotImplementedError] if the method is not implemented.
    # @return [void]
    #
    # @example
    #   class MyStore
    #     include LlmMemory::Store
    #     register_store :my_store
    #     def delete
    #       # Implementation to delete data
    #     end
    #   end
    def delete
      raise NotImplementedError, "Each store must implement the 'delete' method."
    end

    # Searches data in the store.
    #
    # This method must be implemented by any class that includes the Store module.
    # It is responsible for searching data in the store.
    #
    # @raise [NotImplementedError] if the method is not implemented.
    # @return [Object] The search results.
    #
    # @example
    #   class MyStore
    #     include LlmMemory::Store
    #     register_store :my_store
    #     def search
    #       # Implementation to search data
    #       ["result1", "result2"]
    #     end
    #   end
    def search
      raise NotImplementedError, "Each store must implement the 'search' method."
    end
  end

  # The StoreManager class manages registered store classes.
  #
  # It provides a way to register and retrieve store classes by name.
  class StoreManager
    @stores = {}

    # Registers a store class.
    #
    # @param name [Symbol] The name to register the store class under.
    # @param klass [Class] The store class to register.
    def self.register_store(name, klass)
      @stores[name] = klass
    end

    class << self
      # @return [Hash{Symbol => Class}] A hash of registered store classes.
      attr_reader :stores
    end
  end
end
