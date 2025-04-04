# frozen_string_literal: true

require_relative 'lib/llm_memory/version'

Gem::Specification.new do |spec|
  spec.name = 'llm_memory'
  spec.version = LlmMemory::VERSION
  spec.authors = ['Shohei Kameda', 'Robert Pannick']
  spec.email = ['rwpannick@gmail.com', 'shohey1226@gmail.com']

  spec.summary = 'A Ruby spec.add_dependency for LLMs like ChatGPT to have memory using in-context learning'
  spec.description = 'LLM Memory is a Ruby spec.add_dependency designed to provide large language models (LLMs) like ChatGPT with memory using in-context learning. This enables better integration with systems such as Rails and web services while providing a more user-friendly and abstract interface based on brain terms.'
  spec.homepage = 'https://github.com/b08x/llm_memory'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/b08x/llm_memory'
  spec.metadata['changelog_uri'] = 'https://github.com/b08x/llm_memory/CHANGELOG.md'

  # Specify which files should be added to the spec.add_dependency when it is released.
  # The `git ls-files -z` loads the files in the Rubyspec.add_dependency that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-minitest'
  spec.add_development_dependency 'rubocop-packaging'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'ruby-lsp'
  spec.add_development_dependency 'solargraph'

  spec.add_dependency 'dotenv'
  spec.add_dependency 'google_custom_search_api'
  spec.add_dependency 'highline'
  spec.add_dependency 'json'
  spec.add_dependency 'jsonl'
  spec.add_dependency 'lingua'
  spec.add_dependency 'mimemagic'
  spec.add_dependency 'mime-types'
  spec.add_dependency 'numpy'
  spec.add_dependency 'ohm'
  spec.add_dependency 'ohm-contrib'
  spec.add_dependency 'omniai-google', '~> 2.2'
  spec.add_dependency 'omniai-mistral', '~> 2.2'
  spec.add_dependency 'omniai-openai', '~> 2.2'
  spec.add_dependency 'os'
  spec.add_dependency 'pdf-reader'
  spec.add_dependency 'pry'
  spec.add_dependency 'puma'
  spec.add_dependency 'pycall'
  spec.add_dependency 'rake', '~> 13.0'
  spec.add_dependency 'redis'
  spec.add_dependency 'redis-namespace'
  spec.add_dependency 'rspec', '~> 3.0'
  spec.add_dependency 'ruby-openai'
  spec.add_dependency 'ruby-spacy'
  spec.add_dependency 'sass'
  spec.add_dependency 'scalpel'
  spec.add_dependency 'sequel'
  spec.add_dependency 'sinatra'
  spec.add_dependency 'sinatra-contrib'
  spec.add_dependency 'sprockets'
  spec.add_dependency 'standard', '~> 1.3'
  spec.add_dependency 'timeout'
  spec.add_dependency 'tokenizers'
  spec.add_dependency 'treetop'
  spec.add_dependency 'tty-box'
  spec.add_dependency 'tty-markdown'
  spec.add_dependency 'tty-prompt'
  spec.add_dependency 'tty-screen'
  spec.add_dependency 'tty-spinner'
  spec.add_dependency 'tty-table'
  spec.add_dependency 'vcr', '~> 6.1.0'
  spec.add_dependency 'webmock', '~> 3.18.1'
  spec.add_dependency 'wordnet'
  spec.add_dependency 'wordnet-defaultdb'
  spec.add_dependency 'yajl-ruby', '~> 1.4'
  spec.add_dependency 'yaml'

  # For more information and examples about making a new spec.add_dependency, check out our
  # guide at: https://bundler.io/guides/creating_spec.add_dependency.html
end
