# frozen_string_literal: true

# require 'ruby-spacy'
# require 'tf-idf-similarity'
# require 'bm25'
# require 'ohm'
# require 'ohm/contrib'

require_relative 'store'
require_relative 'stores/redis_store'
require_relative 'stores/pgvector_store'

require_relative 'embedding'
require_relative 'embeddings/openai'
require_relative 'embeddings/gemini'

module LlmMemory
  # The Hippocampus class is responsible for managing the memory of the LLM.
  # It handles the chunking of documents, embedding them into vectors,
  # and storing/retrieving them from a specified store.
  class Hippocampus
    # @param embedding_name [Symbol] The name of the embedding to use. Defaults to :openai.
    # @param chunk_size [Integer] The size of each chunk. Defaults to 1024.
    # @param chunk_overlap [Integer] The overlap between chunks. Defaults to 50.
    # @param store [Symbol] The name of the store to use. Defaults to :redis.
    # @param index_name [String] The name of the index in the store. Defaults to 'llm_memory'.
    # @raise [RuntimeError] if the embedding or store is not found.
    def initialize(
      embedding_name: :gemini,
      chunk_size: 1024,
      chunk_overlap: 50,
      store: :pgvector,
      index_name: 'llm_memory'
    )
      LlmMemory.configure

      embedding_class = EmbeddingManager.embeddings[embedding_name]
      raise "Embedding '#{embedding_name}' not found." unless embedding_class

      @embedding_instance = embedding_class.new

      store_class = StoreManager.stores[store]
      raise "Store '#{store}' not found." unless store_class

      @store = store_class.new(index_name: index_name)

      # char count, not word count
      @chunk_size = chunk_size
      @chunk_overlap = chunk_overlap
    end

    # Validates the format of the documents.
    #
    # @param documents [Array<Hash>] An array of documents. Each document should be a hash with :content and :metadata keys.
    # @raise [RuntimeError] if the documents are not in the correct format.
    # @return [void]
    def validate_documents(documents)
      is_valid = documents.all? do |hash|
        hash.is_a?(Hash) &&
          hash.key?(:content) && hash[:content].is_a?(String) &&
          hash.key?(:metadata) && hash[:metadata].is_a?(Hash)
      end
      return if is_valid

      raise 'Your documents need to have an array of hashes (content: string and metadata: hash)'
    end

    # Memorizes the given documents.
    #
    # @param docs [Array<Hash>] An array of documents to memorize.
    # @return [void]
    def memorize(docs)
      validate_documents(docs)
      docs = make_chunks(docs)
      docs = add_vectors(docs)
      @store.create_index unless @store.index_exists?
      @store.add(data: docs)
    end

    # Queries the store for documents similar to the query string.
    #
    # @param query_str [String] The query string.
    # @param limit [Integer] The maximum number of results to return. Defaults to 3.
    # @return [Array<Hash>] An array of documents that match the query.
    def query(query_str, limit: 3)
      vector = @embedding_instance.embed_document(query_str)
      @store.search(query: vector, k: limit)
    end

    # Forgets all documents in the store.
    #
    # @return [void]
    def forget_all
      @store.drop_index if @store.index_exists?
    end

    # Forgets a specific document by its key.
    #
    # @param key [String] The key of the document to forget.
    # @return [void]
    def forget(key)
      @store.delete(key)
    end

    # Lists all keys in the store.
    #
    # @param args [Array] Arguments to pass to the store's list method.
    # @return [Array<String>] An array of keys.
    def list(*args)
      @store.list(*args)
    end

    # Gets a specific document by its key.
    #
    # @param key [String] The key of the document to get.
    # @return [Hash, nil] The document if found, nil otherwise.
    def get(key)
      @store.get(key)
    end

    # Adds vectors to the given documents.
    #
    # @param docs [Array<Hash>] An array of documents.
    # @return [Array<Hash>] An array of documents with vectors added.
    def add_vectors(docs)
      # embed documents and add vector
      result = []
      docs.each do |doc|
        content = doc[:content]
        metadata = doc[:metadata]
        vector = @embedding_instance.embed_document(content)
        result.push({
                      content: content,
                      metadata: metadata,
                      vector: vector
                    })
      end
      result
    end

    # Chunks the given documents into smaller pieces.
    #
    # @param docs [Array<Hash>] An array of documents.
    # @return [Array<Hash>] An array of chunked documents.
    def make_chunks(docs)
      result = []
      docs.each do |item|
        content = item[:content]
        metadata = item[:metadata]
        if content.length > @chunk_size
          start_index = 0
          while start_index < content.length
            end_index = [start_index + @chunk_size, content.length].min
            chunk = content[start_index...end_index]
            result << { content: chunk, metadata: metadata }
            break if end_index == content.length

            start_index += @chunk_size - @chunk_overlap
          end
        else
          result << { content: content, metadata: metadata }
        end
      end
      result
    end
  end
end
