# frozen_string_literal: true

require_relative 'configuration/base'
require_relative 'configuration/openai'
require_relative 'configuration/openrouter'
require_relative 'configuration/gemini'
require_relative 'configuration/mistral'
require_relative 'configuration/huggingface'
# require_relative 'configuration/groq'

module LlmMemory
  # The main configuration class for the LlmMemory gem.
  #
  # This class provides a central place to configure various aspects of the gem,
  # including API keys, default models, and other settings for different LLM providers.
  #
  # @example Configure the gem with API keys
  #   LlmMemory.configure do |config|
  #     config.openai.access_token = 'your_openai_api_key'
  #     config.gemini.api_key = 'your_gemini_api_key'
  #     config.openrouter.api_key = 'your_openrouter_api_key'
  #     config.mistral.api_key = 'your_mistral_api_key'
  #     config.huggingface.api_key = 'your_huggingface_api_key'
  #     config.base.redis_url = 'redis://localhost:6379'
  #     config.base.pg_url = 'postgres://user:password@host:port/database'
  #   end
  class Configuration
    # @return [LlmMemory::Config::Base] The base configuration settings.
    attr_reader :base
    # @return [LlmMemory::Config::OpenAI] The OpenAI-specific configuration settings.
    attr_reader :openai
    # @return [LlmMemory::Config::Gemini] The Gemini-specific configuration settings.
    attr_reader :gemini
    # @return [LlmMemory::Config::OpenRouter] The OpenRouter-specific configuration settings.
    attr_reader :openrouter
    # @return [LlmMemory::Config::Mistral] The Mistral-specific configuration settings.
    attr_reader :mistral
    # @return [LlmMemory::Config::HuggingFace] The HuggingFace-specific configuration settings.
    attr_reader :huggingface
    # @return [LlmMemory::Config::Groq] The Groq-specific configuration settings.
    # attr_reader :groq

    # @!attribute openai_access_token
    #   @return [String] The OpenAI access token.
    #   @deprecated Use {LlmMemory::Config::OpenAI#access_token} instead.
    # @!attribute openai_organization_id
    #   @return [String] The OpenAI organization ID.
    #   @deprecated Use {LlmMemory::Config::OpenAI#organization_id} instead.
    # @!attribute redis_url
    #   @return [String] The Redis URL.
    #   @deprecated Use {LlmMemory::Config::Base#redis_url} instead.
    attr_accessor :openai_access_token, :openai_organization_id, :gemini_api_key

    attr_writer :pg_url

    # Initializes a new Configuration instance.
    #
    # Sets up the default configuration for each LLM provider.
    #
    # @return [void]
    def initialize
      @base = Config::Base.new
      @openai = Config::OpenAI.new
      @openrouter = Config::OpenRouter.new
      @gemini = Config::Gemini.new
      @mistral = Config::Mistral.new
      @huggingface = Config::HuggingFace.new
      # @groq = Configuration::Groq.new

      # For backward compatibility
      @openai_api_key = @openai.access_token
      @openai_organization_id = @openai.organization_id
      @gemini_api_key = @gemini.api_key

      @redis_url = @base.redis_url
      @pg_url = @base.pg_url
    end

    # @!group Backward Compatibility Methods

    # Returns the PostgreSQL connection URL.
    #
    # @raise [LlmMemory::ConfigurationError] if the PostgreSQL connection URL is not set.
    # @return [String] The PostgreSQL connection URL.
    def pg_url
      return @pg_url if @pg_url

      error_text = 'Missing Connection URIs See https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING'
      raise ConfigurationError, error_text
    end

    # @return [String] The Gemini API key.
    # @deprecated Use {LlmMemory::Config::Gemini#api_key} instead.
    def gemini_api_key
      @gemini.api_key
    end

    # Sets the Gemini API key.
    # @param value [String] The new Gemini API key.
    # @deprecated Use {LlmMemory::Config::Gemini#api_key=} instead.
    def gemini_api_key=(value)
      @gemini.api_key = value
    end

    # @return [String] The default Gemini model.
    # @deprecated Use {LlmMemory::Config::Gemini#default_model} instead.
    def gemini_default_model
      @gemini.default_model
    end

    # Sets the default Gemini model.
    # @param value [String] The new default Gemini model.
    # @deprecated Use {LlmMemory::Config::Gemini#default_model=} instead.
    def gemini_default_model=(value)
      @gemini.default_model = value
    end

    # @return [String] The OpenRouter API key.
    # @deprecated Use {LlmMemory::Config::OpenRouter#api_key} instead.
    def openrouter_api_key
      @openrouter.api_key
    end

    # Sets the OpenRouter API key.
    # @param value [String] The new OpenRouter API key.
    # @deprecated Use {LlmMemory::Config::OpenRouter#api_key=} instead.
    def openrouter_api_key=(value)
      @openrouter.api_key = value
    end

    # @return [String] The default OpenRouter model.
    # @deprecated Use {LlmMemory::Config::OpenRouter#default_model} instead.
    def openrouter_default_model
      @openrouter.default_model
    end

    # Sets the default OpenRouter model.
    # @param value [String] The new default OpenRouter model.
    # @deprecated Use {LlmMemory::Config::OpenRouter#default_model=} instead.
    def openrouter_default_model=(value)
      @openrouter.default_model = value
    end

    # @return [String] The OpenRouter host.
    # @deprecated Use {LlmMemory::Config::OpenRouter#host} instead.
    def openrouter_host
      @openrouter.host
    end

    # Sets the OpenRouter host.
    # @param value [String] The new OpenRouter host.
    # @deprecated Use {LlmMemory::Config::OpenRouter#host=} instead.
    def openrouter_host=(value)
      @openrouter.host = value
    end

    # @return [String] The Mistral API key.
    # @deprecated Use {LlmMemory::Config::Mistral#api_key} instead.
    def mistral_api_key
      @mistral.api_key
    end

    # Sets the Mistral API key.
    # @param value [String] The new Mistral API key.
    # @deprecated Use {LlmMemory::Config::Mistral#api_key=} instead.
    def mistral_api_key=(value)
      @mistral.api_key = value
    end

    # @return [String] The default Mistral model.
    # @deprecated Use {LlmMemory::Config::Mistral#default_model} instead.
    def mistral_default_model
      @mistral.default_model
    end

    # Sets the default Mistral model.
    # @param value [String] The new default Mistral model.
    # @deprecated Use {LlmMemory::Config::Mistral#default_model=} instead.
    def mistral_default_model=(value)
      @mistral.default_model = value
    end

    # @return [String] The Mistral host.
    # @deprecated Use {LlmMemory::Config::Mistral#host} instead.
    def mistral_host
      @mistral.host
    end

    # Sets the Mistral host.
    # @param value [String] The new Mistral host.
    # @deprecated Use {LlmMemory::Config::Mistral#host=} instead.
    def mistral_host=(value)
      @mistral.host = value
    end

    # @return [String] The HuggingFace API key.
    # @deprecated Use {LlmMemory::Config::HuggingFace#api_key} instead.
    def huggingface_api_key
      @huggingface.api_key
    end

    # Sets the HuggingFace API key.
    # @param value [String] The new HuggingFace API key.
    # @deprecated Use {LlmMemory::Config::HuggingFace#api_key=} instead.
    def huggingface_api_key=(value)
      @huggingface.api_key = value
    end

    # @return [String] The default HuggingFace model.
    # @deprecated Use {LlmMemory::Config::HuggingFace#default_model} instead.
    def huggingface_default_model
      @huggingface.default_model
    end

    # Sets the default HuggingFace model.
    # @param value [String] The new default HuggingFace model.
    # @deprecated Use {LlmMemory::Config::HuggingFace#default_model=} instead.
    def huggingface_default_model=(value)
      @huggingface.default_model = value
    end

    # @return [String] The HuggingFace embedding model.
    # @deprecated Use {LlmMemory::Config::HuggingFace#embedding_model} instead.
    def huggingface_embedding_model
      @huggingface.embedding_model
    end

    # Sets the HuggingFace embedding model.
    # @param value [String] The new HuggingFace embedding model.
    # @deprecated Use {LlmMemory::Config::HuggingFace#embedding_model=} instead.
    def huggingface_embedding_model=(value)
      @huggingface.embedding_model = value
    end

    # @return [String] The Groq API key.
    # @deprecated Use {LlmMemory::Config::Groq#api_key} instead.
    def groq_api_key
      # @groq.api_key
    end

    # Sets the Groq API key.
    # @param value [String] The new Groq API key.
    # @deprecated Use {LlmMemory::Config::Groq#api_key=} instead.
    def groq_api_key=(value)
      # @groq.api_key = value
    end

    # @return [String] The default Groq model.
    # @deprecated Use {LlmMemory::Config::Groq#default_model} instead.
    def groq_default_model
      # @groq.default_model
    end

    # Sets the default Groq model.
    # @param value [String] The new default Groq model.
    # @deprecated Use {LlmMemory::Config::Groq#default_model=} instead.
    def groq_default_model=(value)
      # @groq.default_model = value
    end

    # @return [String] The API endpoint.
    # @deprecated Use {LlmMemory::Config::Base#api_endpoint} instead.
    def api_endpoint
      @base.api_endpoint
    end

    # Sets the API endpoint.
    # @param value [String] The new API endpoint.
    # @deprecated Use {LlmMemory::Config::Base#api_endpoint=} instead.
    def api_endpoint=(value)
      @base.api_endpoint = value
    end

    # @!endgroup
  end
end
