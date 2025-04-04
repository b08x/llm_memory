# frozen_string_literal: true

require_relative '../embedding'
require_relative '../llms/openai'

module LlmMemory
  module Embeddings
    # The Openai class provides embedding functionality using the OpenAI API.
    #
    # It allows you to generate embeddings for both single documents and multiple documents.
    #
    # @example Embed a single document
    #   openai_embedding = LlmMemory::Embeddings::Openai.new
    #   document_embedding = openai_embedding.embed_document("This is a document.")
    # @example Embed multiple documents
    #   openai_embedding = LlmMemory::Embeddings::Openai.new
    #   documents_embeddings = openai_embedding.embed_documents(["Document 1", "Document 2"])
    class Openai
      include LlmMemory::Embedding
      include Llms::Openai

      register_embedding :openai

      # Embeds multiple documents using the OpenAI API.
      #
      # @param texts [Array<String>] An array of text documents to embed.
      # @param model [String] The model to use for embedding. Defaults to 'text-embedding-ada-002'.
      # @return [Array<Array<Float>>] An array of embeddings, where each embedding is an array of floats.
      # @raise [StandardError] if there is an error during the embedding process.
      #
      # @example
      #   openai_embedding = LlmMemory::Embeddings::Openai.new
      #   documents_embeddings = openai_embedding.embed_documents(["Document 1", "Document 2"])
      def embed_documents(texts, model: 'text-embedding-ada-002')
        embedding_list = []
        texts.each do |txt|
          res = client.embeddings(
            parameters: {
              model: model,
              input: txt
            }
          )
          embedding_list.push(res['data'][0]['embedding'])
        end
        embedding_list
      end

      # Embeds a single document using the OpenAI API.
      #
      # @param text [String] The text document to embed.
      # @param model [String] The model to use for embedding. Defaults to 'text-embedding-ada-002'.
      # @return [Array<Float>] The embedding of the document as an array of floats.
      # @raise [StandardError] if there is an error during the embedding process.
      #
      # @example
      #   openai_embedding = LlmMemory::Embeddings::Openai.new
      #   document_embedding = openai_embedding.embed_document("This is a document.")
      def embed_document(text, model: 'text-embedding-ada-002')
        res = client.embeddings(
          parameters: {
            model: model,
            input: text
          }
        )
        res['data'][0]['embedding']
      end
    end
  end
end
