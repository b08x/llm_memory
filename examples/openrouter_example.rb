#!/usr/bin/env ruby
# frozen_string_literal: true

require 'llm_memory'

# Example prompt for translation
prompt = 'Translate the following English text to French: <%= text %>'

# Initialize Broca with OpenRouter provider and Claude model
broca = LlmMemory::Broca.new(
  prompt: prompt,
  provider: :openrouter,
  model: 'anthropic/claude-3-sonnet' # Use the full model identifier
)

# Send a request to translate text
response = broca.respond(text: 'Hello, world!')
puts "Translation: #{response}"

# Example with a different model
gpt_broca = LlmMemory::Broca.new(
  prompt: 'Answer the following question: <%= question %>',
  provider: :openrouter,
  model: 'openai/gpt-4' # Use the full model identifier
)

# Send a request to answer a question
answer = gpt_broca.respond(question: 'What is the capital of France?')
puts "Answer: #{answer}"
