# frozen_string_literal: true

require 'erb'
require 'tokenizers'

require_relative 'llms/openai'
require_relative 'llms/openrouter'
require_relative 'llms/gemini'
require_relative 'llms/mistral'
require_relative 'llms/huggingface'

module LlmMemory
  # The Broca class is responsible for interacting with a Large Language Model (LLM),
  # such as OpenAI's GPT models, Google's Gemini, or models via OpenRouter.
  # It handles prompt generation, sending requests to the LLM,
  # and managing the conversation history. It also includes functionality for adjusting
  # the token count to stay within the model's limits and for formatting responses
  # according to a specified schema.
  class Broca
    attr_accessor :messages
    attr_reader :provider

    # Initializes a new Broca instance.
    #
    # @param prompt [String] The base prompt to use for generating responses.
    # @param provider [Symbol] The LLM provider to use (:openrouter, :openai, or :gemini). Defaults to :openrouter.
    # @param model [String] The name of the LLM model to use (e.g., 'gpt-3.5-turbo', 'gemini-pro'). Defaults to 'gpt-3.5-turbo'.
    # @param temperature [Float] Controls the randomness of the LLM's output. Higher values (e.g., 1.0) make the output more random, while lower values (e.g., 0.2) make it more focused and deterministic. Defaults to 0.7.
    # @param max_token [Integer] The maximum number of tokens allowed in the conversation history. Defaults to 4096.
    def initialize(
      prompt:,
      provider: :openrouter,
      model: 'gpt-3.5-turbo',
      temperature: 0.7,
      max_token: 4096
    )
      LlmMemory.configure
      @provider = provider.to_sym
      @model = model
      @prompt = prompt
      @messages = []
      @temperature = temperature
      @max_token = max_token
      include_provider(@provider)
    end

    # Includes the appropriate provider module based on the specified provider.
    #
    # @param provider [Symbol] The provider to include.
    # @return [void]
    def include_provider(provider)
      case provider
      when :openai
        extend LlmMemory::Llms::Openai
      when :openrouter
        extend LlmMemory::Llms::OpenRouter
      when :gemini
        extend LlmMemory::Llms::Gemini
      when :mistral
        extend LlmMemory::Llms::Mistral
      when :huggingface
        extend LlmMemory::Llms::HuggingFace
      else
        raise ArgumentError, "Unsupported provider: #{provider}"
      end
    end

    # Sends a request to the LLM and returns the response.
    #
    # @param args [Hash] A hash of arguments to be used in the prompt.
    # @return [String, nil] The LLM's response as a string, or nil if an error occurs.
    def respond(args)
      final_prompt = generate_prompt(args)
      @messages.push({ role: 'user', content: final_prompt })
      adjust_token_count
      begin
        response = send_chat_request(
          model: @model,
          messages: @messages,
          temperature: @temperature
        )
        logger.debug(response)
        p response
        response_content = response.dig('choices', 0, 'message', 'content')
        @messages.push({ role: 'system', content: response_content }) unless response_content.nil?
        response_content
      rescue StandardError => e
        logger.info(e.inspect)
        # @messages = []
        nil
      end
    end

    # Sends a request to the LLM and attempts to format the response according to a specified schema.
    #
    # @param context [Hash] A hash of arguments to be used in the initial prompt.
    # @param schema [Hash] A JSON schema defining the desired format of the response.
    # @return [Hash, nil] The formatted response as a hash, or nil if an error occurs or the response cannot be formatted.
    def respond_with_schema(context: {}, schema: {})
      response_content = respond(context)
      begin
        # NOTE: Function calling is primarily supported by OpenAI models
        # For Gemini, we would need to adapt this approach or use a different method
        response = send_chat_request(
          model: schema_model_for_provider,
          messages: [
            {
              role: 'user',
              content: response_content
            }
          ],
          functions: [
            {
              name: 'broca',
              description: 'Formating the content with the specified schema',
              parameters: schema
            }
          ]
        )
        logger.debug(response)
        message = response.dig('choices', 0, 'message')
        if message['role'] == 'assistant' && message['function_call']
          function_name = message.dig('function_call', 'name')
          args =
            JSON.parse(
              message.dig('function_call', 'arguments'),
              { symbolize_names: true }
            )
          args if function_name == 'broca'
        end
      rescue StandardError => e
        logger.info(e.inspect)
        nil
      end
    end

    # Generates the final prompt to be sent to the LLM by combining the base prompt with the given arguments.
    #
    # @param args [Hash] A hash of arguments to be used in the prompt.
    # @return [String] The generated prompt.
    def generate_prompt(args)
      erb = ERB.new(@prompt)
      erb.result_with_hash(args)
    end

    # Adjusts the conversation history to stay within the maximum token limit.
    # Removes older messages until the total token count is within the limit.
    #
    # @return [void]
    def adjust_token_count
      count = 0
      new_messages = []
      @messages.reverse_each do |message|
        encoded = tokenizer.encode(message[:content], add_special_tokens: true)
        token_count = encoded.tokens.length
        count += token_count
        break unless count <= @max_token

        new_messages.push(message)
      end
      @messages = new_messages.reverse
    end

    # Returns the tokenizer instance.
    #
    # @return [Tokenizers::Tokenizer] The tokenizer instance.
    def tokenizer
      @tokenizer ||= Tokenizers.from_pretrained('gpt2')
    end

    private

    # Sends a chat request to the appropriate LLM provider based on the configured provider.
    #
    # @param parameters [Hash] Parameters for the chat request.
    # @return [Hash] The response from the LLM provider.
    def send_chat_request(parameters)
      case @provider
      when :openrouter
        client.chat(parameters: parameters)
      when :mistral
        mistral_chat(parameters)
      when :openai
        openai_chat(parameters)
      when :gemini
        gemini_chat(parameters)
      when :huggingface
        huggingface_chat(parameters)
      else
        raise "Unsupported provider: #{@provider}"
      end
    end

    # Returns the appropriate model for schema formatting based on the provider.
    #
    # @return [String] The model name to use for schema formatting.
    def schema_model_for_provider
      case @provider
      when :gemini
        # Gemini doesn't support function calling in the same way as OpenAI
        # For now, we'll use a default OpenAI model for schema formatting
        'gpt-3.5-turbo-0613'
      else
        'gpt-3.5-turbo-0613'
      end
    end
  end
end
