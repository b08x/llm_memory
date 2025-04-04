# frozen_string_literal: true

require_relative '../embedding'
require_relative '../llms/mistral'

module LlmMemory
  module Embeddings
    # The Mistral class provides embedding functionality using the Mistral API.
    #
    # It allows you to generate embeddings for both single documents and multiple documents.
    #
    # @example
    #   mistral_embedding = LlmMemory::Embeddings::Mistral.new
    #   document_embedding = mistral_embedding.embed_document("This is a document.")
    #   documents_embeddings = mistral_embedding.embed_documents(["Document 1", "Document 2"])
    class Mistral
      include LlmMemory::Embedding
      include Llms::Mistral

      register_embedding :mistral

      # Embeds multiple documents using the Mistral API.
      #
      # @param texts [Array<String>] An array of text documents to embed.
      # @param model [String] The model to use for embedding. Defaults to 'mistral-embed'.
      # @return [Array<Array<Float>>] An array of embeddings, where each embedding is an array of floats.
      # @raise [StandardError] if there is an error during the embedding process.
      #
      # @example
      #   mistral_embedding = LlmMemory::Embeddings::Mistral.new
      #   documents_embeddings = mistral_embedding.embed_documents(["Document 1", "Document 2"])
      def embed_documents(texts, model: 'mistral-embed')
        embedding_list = []
        texts.each do |txt|
          res = client.embed(txt)
          embedding_list.push(res.embedding)
        end
        embedding_list
      end

      # Embeds a single document using the Mistral API.
      #
      # @param text [String] The text document to embed.
      # @param model [String] The model to use for embedding. Defaults to 'mistral-embed'.
      # @return [Array<Float>] The embedding of the document as an array of floats.
      # @raise [StandardError] if there is an error during the embedding process.
      #
      # @example
      #   mistral_embedding = LlmMemory::Embeddings::Mistral.new
      #   document_embedding = mistral_embedding.embed_document("This is a document.")
      def embed_document(text, model: 'mistral-embed')
        res = client.embed(text)
        res.embedding
      end
    end
  end
end
