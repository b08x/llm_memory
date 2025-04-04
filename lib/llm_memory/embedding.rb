# frozen_string_literal: true

# lib/llm_memory/embedding.rb
module LlmMemory
  # The Embedding module provides a base interface for embedding classes.
  #
  # It defines the necessary methods for registering and using embedding models.
  # Embedding models are used to convert text into numerical vectors.
  module Embedding
    # This method is called when the module is included in a class.
    # It extends the including class with the ClassMethods module.
    #
    # @param base [Class] The class that includes this module.
    def self.included(base)
      base.extend(ClassMethods)
    end

    # The ClassMethods module provides class-level methods for embedding classes.
    module ClassMethods
      # Registers an embedding class with the EmbeddingManager.
      #
      # This allows the embedding class to be used by name later.
      #
      # @param name [Symbol] The name to register the embedding class under.
      # @param klass [Class] The embedding class to register.
      #
      # @example
      #   class MyEmbedding
      #     include LlmMemory::Embedding
      #     register_embedding :my_embedding
      #   end
      def register_embedding(name)
        LlmMemory::EmbeddingManager.register_embedding(name, self)
      end
    end

    # Embeds a single document.
    #
    # This method must be implemented by any class that includes the Embedding module.
    # It is responsible for converting a text document into an embedding vector.
    #
    # @param text [String] The text document to embed.
    # @raise [NotImplementedError] if the method is not implemented.
    # @return [Array<Float>] The embedding vector.
    #
    # @example
    #   class MyEmbedding
    #     include LlmMemory::Embedding
    #     register_embedding :my_embedding
    #     def embed_document(text)
    #       # Implementation to embed the text
    #       [0.1, 0.2, 0.3]
    #     end
    #   end
    def embed_document(text)
      raise NotImplementedError, "Each Embedding must implement the 'embed_document' method."
    end
  end

  # The EmbeddingManager class manages registered embedding classes.
  #
  # It provides a way to register and retrieve embedding classes by name.
  class EmbeddingManager
    @embeddings = {}

    # Registers an embedding class.
    #
    # @param name [Symbol] The name to register the embedding class under.
    # @param klass [Class] The embedding class to register.
    def self.register_embedding(name, klass)
      @embeddings[name] = klass
    end

    class << self
      # @return [Hash{Symbol => Class}] A hash of registered embedding classes.
      attr_reader :embeddings
    end
  end
end
