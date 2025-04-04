#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../embedding'
require_relative '../llms/gemini'

module LlmMemory
  module Embeddings
    # The Gemini class provides embedding functionality using the Gemini API.
    #
    # It allows you to generate embeddings for both single documents and multiple documents.
    #
    # @example
    #   gemini_embedding = LlmMemory::Embeddings::Gemini.new
    #   document_embedding = gemini_embedding.embed_document("This is a document.")
    #   documents_embeddings = gemini_embedding.embed_documents(["Document 1", "Document 2"])
    class Gemini
      include LlmMemory::Embedding
      include Llms::Gemini

      register_embedding :gemini

      # Embeds multiple documents using the Gemini API.
      #
      # @param texts [Array<String>] An array of text documents to embed.
      # @param model [String] The model to use for embedding. Defaults to 'text-embedding-004'.
      # @return [Array<Array<Float>>] An array of embeddings, where each embedding is an array of floats.
      # @raise [StandardError] if there is an error during the embedding process.
      #
      # @example
      #   gemini_embedding = LlmMemory::Embeddings::Gemini.new
      #   documents_embeddings = gemini_embedding.embed_documents(["Document 1", "Document 2"])
      def embed_documents(texts, model: 'text-embedding-004')
        embedding_list = []
        texts.each do |txt|
          res = client.embed(txt)
          embedding_list.push(res.embedding)
        end
        embedding_list
      end

      # Embeds a single document using the Gemini API.
      #
      # @param text [String] The text document to embed.
      # @param model [String] The model to use for embedding. Defaults to 'text-embedding-004'.
      # @return [Array<Float>] The embedding of the document as an array of floats.
      # @raise [StandardError] if there is an error during the embedding process.
      #
      # @example
      #   gemini_embedding = LlmMemory::Embeddings::Gemini.new
      #   document_embedding = gemini_embedding.embed_document("This is a document.")
      def embed_document(text, model: 'text-embedding-004')
        res = client.embed(text)
        res.embedding
      end
    end
  end
end
