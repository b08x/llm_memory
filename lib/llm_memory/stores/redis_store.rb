# frozen_string_literal: true

require 'redis'
require_relative '../store'
require 'json'

module LlmMemory
  # The RedisStore class provides an interface for interacting with a Redis database to store and retrieve data,
  # particularly vector embeddings and associated metadata.
  class RedisStore
    include Store

    register_store :redis

    # Initializes a new RedisStore instance.
    #
    # @param index_name [String] The name of the Redis index. Defaults to 'llm_memory'.
    # @param content_key [String] The key used to store the content. Defaults to 'content'.
    # @param vector_key [String] The key used to store the vector embedding. Defaults to 'vector'.
    # @param metadata_key [String] The key used to store metadata. Defaults to 'metadata'.
    # @return [RedisStore] A new RedisStore instance.
    def initialize(
      index_name: 'llm_memory',
      content_key: 'content',
      vector_key: 'vector',
      metadata_key: 'metadata'
    )
      @index_name = index_name
      @content_key = content_key
      @vector_key = vector_key
      @metadata_key = metadata_key
      @client = Redis.new(url: ENV.fetch('REDIS_URL'))
    end

    # Retrieves information about the Redis server.
    #
    # @return [String] The result of the Redis INFO command.
    def info
      @client.call(['INFO'])
    end

    # Loads data from a CSV file.
    #
    # @param file_path [String] The path to the CSV file.
    # @return [Array<Array<String>>] The data read from the CSV file.
    def load_data(file_path)
      CSV.read(file_path)
    end

    # Lists all existing RedisSearch indexes.
    #
    # @return [Array<String>] An array of index names.
    def list_indexes
      @client.call('FT._LIST')
    end

    # Checks if a RedisSearch index exists.
    #
    # @return [Boolean] True if the index exists, false otherwise.
    def index_exists?
      begin
        @client.call(['FT.INFO', @index_name])
      rescue StandardError
        return false
      end
      true
    end

    # Drops a RedisSearch index and deletes all associated document hashes.
    #
    # @return [String] The result of the FT.DROPINDEX command.
    def drop_index
      # DD deletes all document hashes
      @client.call(['FT.DROPINDEX', @index_name, 'DD'])
    end

    # Creates a new RedisSearch index.
    #
    # @param dim [Integer] The dimension of the vector embeddings. Defaults to 1536 (for ada-002).
    # @param distance_metric [String] The distance metric to use for vector similarity. Defaults to 'COSINE'.
    # @return [String] The result of the FT.CREATE command.
    def create_index(dim: 1536, distance_metric: 'COSINE')
      # LangChain index
      # schema = (
      #   TextField(name=content_key),
      #   TextField(name=metadata_key),
      #   VectorField(
      #       vector_key,
      #       "FLAT",
      #       {
      #           "TYPE": "FLOAT32",
      #           "DIM": dim,
      #           "DISTANCE_METRIC": distance_metric,
      #       },
      #   ),
      # )
      command = [
        'FT.CREATE', @index_name, 'ON', 'HASH',
        'PREFIX', '1', "#{@index_name}:",
        'SCHEMA',
        @content_key, 'TEXT',
        @metadata_key, 'TEXT',
        @vector_key, 'VECTOR', 'FLAT', 6, 'TYPE', 'FLOAT32', 'DIM', dim, 'DISTANCE_METRIC', distance_metric
      ]
      @client.call(command)
    end

    # Adds data to the Redis store.
    #
    # @param data [Array<Hash>] An array of hashes, where each hash represents a document with 'content', 'vector', and 'metadata' keys.
    # @return [Hash] A hash where keys are the generated Redis keys and values are the associated content.
    def add(data: [])
      result = {}
      @client.pipelined do |pipeline|
        data.each_with_index do |d, _i|
          key = @index_name # index_name:create_time:metadata_timestamp:uuid
          timestamp = d.dig(:metadata, :timestamp)
          key += ":#{Time.now.strftime('%Y%m%d%H%M%S')}"
          key += ":#{timestamp}"
          key += ":#{SecureRandom.hex(8)}"

          meta_json = d[:metadata].nil? ? '' : d[:metadata].to_json # serialize
          vector_value = d[:vector].map(&:to_f).pack('f*')
          pipeline.hset(
            key,
            {
              @content_key => d[:content],
              @vector_key => vector_value,
              @metadata_key => meta_json
            }
          )
          result[key] = d[:content]
        end
      end
      result
    rescue StandardError => e
      # Handle any other errors
      puts "Unexpected Error: #{e.message}"
    end

    # Deletes a document from the Redis store.
    #
    # @param key [String] The key of the document to delete.
    # @return [Integer] The number of keys that were removed.
    def delete(key)
      @client.del(key) if @client.exists?(key)
    end

    # Deletes all documents in the index.
    #
    # @return [void]
    def delete_all
      list.keys.each do |key|
        delete(key)
      end
    end

    # Retrieves a document from the Redis store.
    #
    # @param key [String] The key of the document to retrieve.
    # @return [Hash] The document data as a hash.
    def get(key)
      @client.hgetall(key)
    end

    # Lists keys matching a pattern in the index.
    #
    # @param args [Array<String>] Optional arguments to specify a pattern. If empty, lists all keys in the index.
    # @return [Array<String>] An array of keys matching the pattern.
    def list(*args)
      pattern = "#{@index_name}:#{args.first || '*'}"
      @client.keys(pattern)
    end

    # Updates a document in the Redis store. (Not yet implemented)
    #
    # @return [void]
    def update; end

    # Performs a vector similarity search.
    #
    # @param query [Array<Float>] The query vector.
    # @param k [Integer] The number of nearest neighbors to return. Defaults to 3.
    # @return [Array<Hash>] An array of result hashes, each containing 'vector_score', 'content', and 'metadata'.
    def search(query: [], k: 3)
      packed_query = query.map(&:to_f).pack('f*')
      command = [
        'FT.SEARCH',
        @index_name,
        "*=>[KNN #{k} @vector $blob AS vector_score]",
        'PARAMS',
        2,
        'blob',
        packed_query,
        'SORTBY',
        'vector_score',
        'ASC',
        'LIMIT',
        0,
        k,
        'RETURN',
        3,
        'vector_score',
        @content_key,
        @metadata_key,
        'DIALECT',
        2
      ]
      response_list = @client.call(command)
      response_list.shift # the first one is the size
      # now [redis_key1, [],,, ]
      result = response_list.each_slice(2).to_h.values.map do |v|
        v.each_slice(2).to_h.transform_keys(&:to_sym)
      end
      result.each do |item|
        hash = JSON.parse(item[:metadata])
        item[:metadata] = hash.transform_keys(&:to_sym)
      end
      result
    end
  end
end
