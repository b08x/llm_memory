#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'configuration/base'
require_relative 'configuration/openai'
# require_relative 'configuration/gemini'
require_relative 'configuration/openrouter'
# require_relative 'configuration/mistral'
# require_relative 'configuration/groq'

module LlmMemory
  # The main configuration class for the LlmMemory gem.
  #
  # This class provides a central place to configure various aspects of the gem,
  # including API keys, default models, and other settings for different LLM providers.
  class Configuration
    # @return [Configuration::Base] The base configuration settings.
    attr_reader :base
    # @return [Configuration::OpenAI] The OpenAI-specific configuration settings.
    attr_reader :openai
    # @return [Configuration::Gemini] The Gemini-specific configuration settings.
    # attr_reader :gemini
    # @return [Configuration::OpenRouter] The OpenRouter-specific configuration settings.
    attr_reader :openrouter
    # @return [Configuration::Mistral] The Mistral-specific configuration settings.
    # attr_reader :mistral
    # @return [Configuration::Groq] The Groq-specific configuration settings.
    # attr_reader :groq

    # @!attribute openai_access_token
    #   @return [String] The OpenAI access token.
    #   @deprecated Use {Configuration::OpenAI#access_token} instead.
    # @!attribute openai_organization_id
    #   @return [String] The OpenAI organization ID.
    #   @deprecated Use {Configuration::OpenAI#organization_id} instead.
    # @!attribute redis_url
    #   @return [String] The Redis URL.
    #   @deprecated Use {Configuration::Base#redis_url} instead.
    attr_accessor :openai_access_token, :openai_organization_id

    # Initializes a new Configuration instance.
    #
    # Sets up the default configuration for each LLM provider.
    def initialize
      @base = Config::Base.new
      @openai = Config::OpenAI.new
      # @gemini = Configuration::Gemini.new
      @openrouter = Config::OpenRouter.new
      # @mistral = Configuration::Mistral.new
      # @groq = Configuration::Groq.new

      # For backward compatibility
      @openai_api_key = @openai.api_key
      @openai_organization_id = @openai.organization_id
      # @redis_url = @base.redis_url
    end

    # @!group Backward Compatibility Methods

    # @return [String] The Gemini API key.
    # @deprecated Use {Configuration::Gemini#api_key} instead.
    def gemini_api_key
      @gemini.api_key
    end

    # Sets the Gemini API key.
    # @param value [String] The new Gemini API key.
    # @deprecated Use {Configuration::Gemini#api_key=} instead.
    def gemini_api_key=(value)
      @gemini.api_key = value
    end

    # @return [String] The default Gemini model.
    # @deprecated Use {Configuration::Gemini#default_model} instead.
    def gemini_default_model
      @gemini.default_model
    end

    # Sets the default Gemini model.
    # @param value [String] The new default Gemini model.
    # @deprecated Use {Configuration::Gemini#default_model=} instead.
    def gemini_default_model=(value)
      @gemini.default_model = value
    end

    # @return [String] The OpenRouter API key.
    # @deprecated Use {Configuration::OpenRouter#api_key} instead.
    def openrouter_api_key
      @openrouter.api_key
    end

    # Sets the OpenRouter API key.
    # @param value [String] The new OpenRouter API key.
    # @deprecated Use {Configuration::OpenRouter#api_key=} instead.
    def openrouter_api_key=(value)
      @openrouter.api_key = value
    end

    # @return [String] The default OpenRouter model.
    # @deprecated Use {Configuration::OpenRouter#default_model} instead.
    def openrouter_default_model
      @openrouter.default_model
    end

    # Sets the default OpenRouter model.
    # @param value [String] The new default OpenRouter model.
    # @deprecated Use {Configuration::OpenRouter#default_model=} instead.
    def openrouter_default_model=(value)
      @openrouter.default_model = value
    end

    # @return [String] The OpenRouter host.
    # @deprecated Use {Configuration::OpenRouter#host} instead.
    def openrouter_host
      @openrouter.host
    end

    # Sets the OpenRouter host.
    # @param value [String] The new OpenRouter host.
    # @deprecated Use {Configuration::OpenRouter#host=} instead.
    def openrouter_host=(value)
      @openrouter.host = value
    end

    # @return [String] The Mistral API key.
    # @deprecated Use {Configuration::Mistral#api_key} instead.
    def mistral_api_key
      @mistral.api_key
    end

    # Sets the Mistral API key.
    # @param value [String] The new Mistral API key.
    # @deprecated Use {Configuration::Mistral#api_key=} instead.
    def mistral_api_key=(value)
      @mistral.api_key = value
    end

    # @return [String] The default Mistral model.
    # @deprecated Use {Configuration::Mistral#default_model} instead.
    def mistral_default_model
      @mistral.default_model
    end

    # Sets the default Mistral model.
    # @param value [String] The new default Mistral model.
    # @deprecated Use {Configuration::Mistral#default_model=} instead.
    def mistral_default_model=(value)
      @mistral.default_model = value
    end

    # @return [String] The Mistral host.
    # @deprecated Use {Configuration::Mistral#host} instead.
    def mistral_host
      @mistral.host
    end

    # Sets the Mistral host.
    # @param value [String] The new Mistral host.
    # @deprecated Use {Configuration::Mistral#host=} instead.
    def mistral_host=(value)
      @mistral.host = value
    end

    # @return [String] The Groq API key.
    # @deprecated Use {Configuration::Groq#api_key} instead.
    def groq_api_key
      @groq.api_key
    end

    # Sets the Groq API key.
    # @param value [String] The new Groq API key.
    # @deprecated Use {Configuration::Groq#api_key=} instead.
    def groq_api_key=(value)
      @groq.api_key = value
    end

    # @return [String] The default Groq model.
    # @deprecated Use {Configuration::Groq#default_model} instead.
    def groq_default_model
      @groq.default_model
    end

    # Sets the default Groq model.
    # @param value [String] The new default Groq model.
    # @deprecated Use {Configuration::Groq#default_model=} instead.
    def groq_default_model=(value)
      @groq.default_model = value
    end

    # @return [String] The API endpoint.
    # @deprecated Use {Configuration::Base#api_endpoint} instead.
    def api_endpoint
      @base.api_endpoint
    end

    # Sets the API endpoint.
    # @param value [String] The new API endpoint.
    # @deprecated Use {Configuration::Base#api_endpoint=} instead.
    def api_endpoint=(value)
      @base.api_endpoint = value
    end

    # @!endgroup
  end
end
