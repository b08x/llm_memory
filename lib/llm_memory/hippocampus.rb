# frozen_string_literal: true

require 'lingua'
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
    # @param embedding_name [Symbol] The name of the embedding to use. Defaults to :gemini.
    # @param chunk_size [Integer] The target character size of each chunk. Defaults to 1024.
    # @param chunk_overlap [Integer] The target character overlap between chunks. Defaults to 50.
    # @param store [Symbol] The name of the store to use. Defaults to :pgvector.
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

      # Target char count, actual chunk size will vary based on sentence boundaries
      @chunk_size = chunk_size
      @chunk_overlap = chunk_overlap
      # Ensure overlap is smaller than chunk size
      raise ArgumentError, 'chunk_overlap must be less than chunk_size' if @chunk_overlap >= @chunk_size
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

    # Chunks the given documents into smaller pieces based on sentence boundaries using the Lingua gem.
    # Aims to create chunks close to `chunk_size` characters, respecting sentence endings.
    # Implements overlap by retaining trailing sentences from the previous chunk.
    #
    # @param docs [Array<Hash>] An array of documents.
    # @return [Array<Hash>] An array of chunked documents.
    def make_chunks(docs)
      all_chunks = []

      docs.each do |item|
        content = item[:content].to_s.encode('UTF-8', invalid: :replace, undef: :replace).strip # Ensure string and remove leading/trailing whitespace
        metadata = item[:metadata]

        # Use Lingua for sentence splitting
        readability = Lingua::EN::Readability.new(content)
        sentences = readability.sentences.map(&:strip).reject(&:empty?)

        # Handle cases with no sentences or content shorter than chunk size
        if sentences.empty?
          all_chunks << { content: content, metadata: metadata } unless content.empty?
          next
        elsif content.length <= @chunk_size && sentences.length <= 1 # Treat as single unit if short and one sentence
          all_chunks << { content: content, metadata: metadata }
          next
        end

        current_chunk_sentences = []
        current_chunk_len = 0
        sentence_index_for_overlap = 0 # Track where the overlap for the *next* chunk should start

        sentences.each_with_index do |sentence, _i|
          sentence_len = sentence.length
          # Calculate length if sentence is added (plus 1 for space, unless it's the first sentence)
          potential_len = current_chunk_len + (current_chunk_sentences.empty? ? 0 : 1) + sentence_len

          if !current_chunk_sentences.empty? && potential_len > @chunk_size
            # Current chunk is full, finalize it
            chunk_text = current_chunk_sentences.join(' ')
            all_chunks << { content: chunk_text, metadata: metadata }

            # --- Overlap Calculation ---
            # Find the sentence index to start the overlap from, aiming for @chunk_overlap characters
            chunk_text.length
            current_overlap_len = 0
            start_index_found = false

            # Iterate backwards through the sentences of the completed chunk
            (current_chunk_sentences.length - 1).downto(0) do |idx|
              s = current_chunk_sentences[idx]
              # Calculate length including space (except for the very first sentence considered for overlap)
              s_len_with_space = s.length + (idx > 0 ? 1 : 0)

              if current_overlap_len + s_len_with_space >= @chunk_overlap
                # This sentence makes the overlap long enough or too long.
                # The *next* sentence (idx + 1) is where the overlap *should* have started,
                # but since we iterate backwards, `idx` is the first sentence fully *within* the desired overlap window.
                sentence_index_for_overlap = idx
                start_index_found = true
                break
              end
              current_overlap_len += s_len_with_space
            end

            # Fallback: If overlap calculation didn't find a suitable index (e.g., one long sentence),
            # start overlap from the last sentence of the previous chunk.
            sentence_index_for_overlap = current_chunk_sentences.length - 1 unless start_index_found
            # --- End Overlap Calculation ---

            # Start the new chunk with overlapping sentences
            new_chunk_sentences = current_chunk_sentences[sentence_index_for_overlap..] || []

            # Add the current sentence (that caused the split) to the new chunk
            # unless it was already part of the overlap calculation base and is the *only* sentence.
            # This check prevents duplicating the sentence if it was the single sentence causing overflow.
            new_chunk_sentences << sentence if new_chunk_sentences.empty? || new_chunk_sentences.last != sentence

            current_chunk_sentences = new_chunk_sentences
            current_chunk_len = current_chunk_sentences.join(' ').length

          else
            # Add sentence to current chunk
            current_chunk_sentences << sentence
            current_chunk_len = potential_len # Use calculated potential length
          end
        end # sentences.each

        # Add the last remaining chunk
        unless current_chunk_sentences.empty?
          all_chunks << { content: current_chunk_sentences.join(' '), metadata: metadata }
        end
      end # docs.each

      all_chunks
    end
  end # class Hippocampus
end # module LlmMemory
