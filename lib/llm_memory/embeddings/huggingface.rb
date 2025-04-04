# frozen_string_literal: true

require_relative '../embedding'
require_relative '../llms/huggingface'

module LlmMemory
  module Embeddings
    # The HuggingFace class provides embedding functionality using the Hugging Face Inference API.
    #
    # It allows you to generate embeddings for both single documents and multiple documents.
    #
    # @example Embed a single document
    #   huggingface_embedding = LlmMemory::Embeddings::HuggingFace.new
    #   document_embedding = huggingface_embedding.embed_document("This is a document.")
    # @example Embed multiple documents
    #   huggingface_embedding = LlmMemory::Embeddings::HuggingFace.new
    #   documents_embeddings = huggingface_embedding.embed_documents(["Document 1", "Document 2"])
    class HuggingFace
      include LlmMemory::Embedding
      include Llms::HuggingFace

      register_embedding :huggingface

      # Embeds multiple documents using the Hugging Face Inference API.
      #
      # @param texts [Array<String>] An array of text documents to embed.
      # @return [Array<Array<Float>>] An array of embeddings, where each embedding is an array of floats.
      # @raise [StandardError] if there is an error during the embedding process.
      #
      # @example
      #   huggingface_embedding = LlmMemory::Embeddings::HuggingFace.new
      #   documents_embeddings = huggingface_embedding.embed_documents(["Document 1", "Document 2"])
      def embed_documents(texts)
        embedding_list = []
        texts.each do |txt|
          res = client.embed(txt)
          embedding_list.push(res.embedding)
        end
        embedding_list
      end

      # Embeds a single document using the Hugging Face Inference API.
      #
      # @param text [String] The text document to embed.
      # @return [Array<Float>] The embedding of the document as an array of floats.
      # @raise [StandardError] if there is an error during the embedding process.
      #
      # @example
      #   huggingface_embedding = LlmMemory::Embeddings::HuggingFace.new
      #   document_embedding = huggingface_embedding.embed_document("This is a document.")
      def embed_document(text)
        res = client.embed(text)
        res.embedding
      end
    end
  end
end
