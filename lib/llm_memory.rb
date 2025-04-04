# frozen_string_literal: true

lib_dir = File.expand_path(File.join(__dir__, '..', 'lib'))
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)

require 'logger'
# config
require 'llm_memory/configuration'
require 'llm_memory/hippocampus'
require 'llm_memory/broca'
require 'llm_memory/wernicke'
require 'llm_memory/version'

module LlmMemory
  class Error < StandardError; end

  class << self
    attr_accessor :configuration, :log_level

    def logger
      @logger ||= Logger.new($stdout).tap do |logger|
        logger.level = log_level || Logger::INFO
      end
    end
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end
end
