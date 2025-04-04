# 🧠 LLM Memory 🌊🐴

LLM Memory is a Ruby gem that enhances applications using large language models (LLMs) by providing memory through in-context learning. It allows these applications to retain and recall information from previous interactions, enabling more contextually relevant and coherent conversations.

This gem facilitates seamless integration with systems like Rails and web services, offering a user-friendly and abstract interface inspired by brain structures, such as Broca and Wernicke areas, for managing prompts and memories within those applications.

## Key Features

- In-context learning through input prompt context insertion
- Data connectors for various data sources
- Inspired by the Python library, [LlamaIndex](https://github.com/jerryjliu/llama_index)
- Focus on integration with existing systems
- Easy-to-understand abstraction using brain-related terms
- Plugin architecture for custom loader creation and extending LLM support
- Support for multiple LLM providers, including Gemini, Hugging Face, Mistral, and OpenRouter

## Key Components

### Input Processing (Wernicke)

- Handles initial interpretation of all input sources.
- Leverages foundation models (OpenAI, Mistral, Gemini).
- Routes processed information to memory systems.

### Memory Structure

#### Short-Term Memory

- Maintains working context and active dialogue state.
- Holds immediately relevant information for the current conversation.
- Direct connection to response generation.

#### Long-Term Memory

- Implemented via dual storage systems:
  - Redis/RedisSearch for fast vector retrieval.
  - Postgres/pgVector for persistent relational storage.
- Supports semantic recall of historical interactions.

### Processing Components

- **Hippocampus:** Handles memory indexing, semantic chunking, and relevance scoring.
- **Broca:** Generates responses by fusing active context with retrieved memories.

### External Systems

- Knowledge bases and API connectors augment internal memory.
- Memory management module handles forgetting/retention policies.

### Information Flow

The diagram shows clear pathways between components:

- Input sources feed directly to processing.
- Short-term memory receives processed input and recalled long-term memories.
- Long-term memory stores indexed information and supplies relevant context.
- Response generation uses combined memory types for coherent dialogue.

This architecture provides your agent with both immediate conversational awareness and access to deeper historical context, ensuring more natural and contextually appropriate dialogue generation.

## LLM Memory Components

![llm_memory_diagram](docs/updated-llm-memory-diagram.svg)

1. LlmMemory::Wernicke: Responsible for loading external data (currently from files). More loader types are planned for future development.

    > Wernicke's area in brain is involved in the comprehension of written and spoken language

2. LlmMemory::Hippocampus: Handles interaction with vector databases to retrieve relevant information based on the query. It can use either Redis with the Redisearch module or pgvector as the vector database. (Note that Redisearch is a proprietary module and available on RedisCloud, which offers a free plan). The reason for choosing Redis initially was that it is commonly used and easy to integrate with web services. pgvector offers efficient similarity search and retrieval of relevant information.

    > Hippocampus in brain plays important roles in the consolidation of information from short-term memory to long-term memory

3. LlmMemory::Broca: Responds to queries using memories provided by the Hippocampus component. ERB is used for prompt templates.

    > Broca's area in brain is also known as the motor speech area.

## Installation

Install the gem and add to the application's Gemfile by executing:

    bundle add llm_memory

If bundler is not being used to manage dependencies, install the gem by executing:

    gem install llm_memory

### Setup

Set environment variables for the LLM providers and Redis:
`OPENAI_ACCESS_TOKEN`, `GEMINI_API_KEY`, `HUGGINGFACE_API_KEY`, `MISTRAL_API_KEY`, `OPENROUTER_API_KEY`, and `REDISCLOUD_URL`.
You can also set these in the initializer:

```ruby
LlmMemory.configure do |c|
  c.openai_access_token = "xxxxx"
  c.gemini_api_key = "xxxxx"
  c.huggingface_api_key = "xxxxx"
  c.mistral_api_key = "xxxxx"
  c.openrouter_api_key = "xxxxx"
  c.redis_url = "redis://xxxx:6379"
  c.pg_url = "postgresql://user:password@host:port/database" # Required if using pgvector
end
```

To use pgvector, you will also need to:

1. Install the `pgvector` extension in your PostgreSQL database:

    ```sql
    CREATE EXTENSION IF NOT EXISTS vector;
    ```

## Usage

To use LLM Memory, follow these steps:

If you want to use pgvector instead of Redisearch, you can use the plugin. Please check the doc and change the setup steps(2&3).

To use pgvector, initialize Hippocampus with the pgvector store:

```ruby
hippocampus = LlmMemory::Hippocampus.new(store: :pgvector)
```

1. Install the gem: gem install llm_memory
2. Set up Redis with Redisearch module enabled - Go to [Reids Cloud](https://redis.com/redis-enterprise-cloud/overview/) and get the redis url.
3. Configure LLM Memory to connect to your Redis instance
4. Use LlmMemory::Wernicke to load data from your external sources
5. Use LlmMemory::Hippocampus to search for relevant information based on user queries
6. Create and use ERB templates with LlmMemory::Broca to generate responses based on the information retrieved

For the details of each class, please refer to [API reference document](https://github.com/shohey1226/llm_memory/wiki/API-Reference).

```ruby
docs = LlmMemory::Wernicke.load(:file, "/tmp/a_directory")
# docs is just an array of hash.
# You don't have to use load method but
# create own hash with having content and metadata(optional)
# docs = [{
#   content: "Hi there",
#   metadata: {
#     file_name: "a.txt",
#     timestamp: "20201231235959"
#   }
# },,,]

hippocampus = LlmMemory::Hippocampus.new
res = hippocampus.memorize(docs)

query_str = "What is my name?"
related_docs = hippocampus.query(query_str, limit: 3)
#[{
#   vector_score: "0.192698478699",
#   content: "My name is Mike",
#   metadata: { ... }
#},,,]

# ERB
prompt = <<-TEMPLATE
Context information is below.
---------------------
<% related_docs.each do |doc| %>
<%= doc[:content] %>
file: <%= doc[:metadata][:file_name] %>

<% end %>
---------------------
Given the context information and not prior knowledge,
answer the question: <%= query_str %>
TEMPLATE

# OpenAI
broca = LlmMemory::Broca.new(prompt: prompt, provider: :openai, model: 'gpt-3.5-turbo')
message = broca.respond(query_str: query_str, related_docs: related_docs)

# Gemini
broca = LlmMemory::Broca.new(prompt: prompt, provider: :gemini, model: 'gemini-pro')
message = broca.respond(query_str: query_str, related_docs: related_docs)

# Hugging Face
broca = LlmMemory::Broca.new(prompt: prompt, provider: :huggingface, model: 'HuggingFaceH4/zephyr-7b-beta')
message = broca.respond(query_str: query_str, related_docs: related_docs)

# Mistral
broca = LlmMemory::Broca.new(prompt: prompt, provider: :mistral, model: 'mistral-tiny')
message = broca.respond(query_str: query_str, related_docs: related_docs)

# OpenRouter
broca = LlmMemory::Broca.new(prompt: prompt, provider: :openrouter ,model: 'google/palm-2')
message = broca.respond(query_str: query_str, related_docs: related_docs)

...
query_str2 = "How are you?"
related_docs = hippocampus.query(query_str2, limit: 3)
message2 = broca.respond(query_str: query_str2, related_docs: related_docs)
```

## Plugins

The table below provides a list of plugins utilized by llm_memory. The aim is to keep the core llm_memory lightweight while allowing for easy extensibility through the use of plugins.

Install the plugin and update the method.

For example, if you wan to use gmail then,

```
bundle add llm_memory_gmail_loader
```

```ruby
# may need to have require depending on the project
require llm_memory_gmail_loader

```

Please refer to the links for the details.

| Plugin Name             | Type   | Module   | Description            | Link                                                          |
| ----------------------- | ------ | -------- | ---------------------- | ------------------------------------------------------------- |
| llm_memory_gmail_loader | Loader | Wernicke | Loads data from Gmail. | [link](https://github.com/shohey1226/llm_memory_gmail_loader) |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/shohey1226/llm_memory>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/shohey1226/llm_memory/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LlmMemory project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/shohey1226/llm_memory/blob/master/CODE_OF_CONDUCT.md).
