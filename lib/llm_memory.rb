# frozen_string_literal: true

lib_dir = File.expand_path(File.join(__dir__, '..', 'lib'))
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)

require 'llm_memory/logging'
include Logging

require 'dotenv/load'

# Attempts to load the .env file, overwriting existing environment variables.
# If an error occurs, it displays an error message.
begin
  Dotenv.load('.env', overwrite: true)
rescue StandardError => e
  puts "Error loading .env file: #{e.message}"
end

# config
require 'llm_memory/configuration'
require 'llm_memory/hippocampus'
require 'llm_memory/broca'
require 'llm_memory/wernicke'
require 'llm_memory/version'

module LlmMemory
  class Error < StandardError; end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end
end
