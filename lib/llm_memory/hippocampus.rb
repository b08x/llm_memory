require_relative "store"
require_relative "stores/redis_store"

require_relative "embedding"
require_relative "embeddings/openai"

module LlmMemory
  class Hippocampus
    def initialize(
      embedding_name: :openai,
      chunk_size: 1024,
      chunk_overlap: 50,
      store_name: :redis,
      index_name: "llm_memory"
    )
      embedding_class = EmbeddingManager.embeddings[embedding_name]
      raise "Embedding '#{embedding_name}' not found." unless embedding_class
      @embedding_instance = embedding_class.new

      store_class = StoreManager.stores[store_name]
      raise "Store '#{store_name}' not found." unless store_class
      @store = store_class.new(index_name: index_name)

      # word count, not char count
      @chunk_size = chunk_size
      @chunk_overlap = chunk_overlap
    end

    def memorize(docs)
      docs = make_chunks(docs)
      docs = add_vectors(docs)
      @store.create_index unless @store.index_exists?
      @store.add(data: docs)
    end

    def query(query_str, limit: 3)
      vector = @embedding_instance.embed_document(query_str)
      response_list = @store.search(query: vector, k: limit)
      response_list.shift # the first one is the size
      # now [redis_key1, [],,, ]
      result = response_list.each_slice(2).to_h.values.map { |v|
        v.each_slice(2).to_h.transform_keys(&:to_sym)
      }
      result.each do |item|
        item[:metadata] = JSON.parse(item[:metadata])
      end
      result
    end

    def forgot_all
      @store.drop_index
    end

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

    def make_chunks(docs)
      result = []
      docs.each do |item|
        content = item[:content]
        metadata = item[:metadata]
        words = content.split

        if words.length > @chunk_size
          start_index = 0

          while start_index < words.length
            end_index = [start_index + @chunk_size, words.length].min
            chunk_words = words[start_index...end_index]
            chunk = chunk_words.join(" ")
            result << {content: chunk, metadata: metadata}

            start_index += @chunk_size - @chunk_overlap # Move index to create a overlap
          end
        else
          result << {content: content, metadata: metadata}
        end
      end
      result
    end
  end
end
