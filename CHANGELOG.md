## [Unreleased]

## [0.2.0] - 2025-04-04

This release focuses heavily on expanding LLM provider support, enhancing configuration flexibility, and adding new storage and logging capabilities.

### Added

* **LLM Provider Integrations:**
  * Integrated **Google Gemini** provider for chat generation and embeddings (`42795c7`, `8859c6c`).
  * Added **Mistral** LLM support, including embeddings and configuration (`0902dd9`).
  * Integrated **Hugging Face** provider via the Inference API for text generation and embeddings (`1bd61bf`, `0902dd9`, `167803a`).
  * Integrated **OpenRouter** provider support (`e070672`, `8a790fa`).
* **Configuration & Initialization:**
  * Enhanced LLM configurations with default model settings for major providers (Gemini, HuggingFace, Mistral, OpenAI, OpenRouter), falling back to environment variables (`167803a`).
  * Allowed passing `model` directly during `Broca.initialize` (`167803a`).
  * Implemented dynamic loading of provider-specific modules in the `Broca` class based on configuration (`c94af1d`).
  * Added support for loading environment variables from `.env` files using `dotenv` gem (`e070672`).
* **Vector Storage:**
  * Implemented **pgvector** support as a vector storage option, including configuration and dependencies (`fceb587`, `b87428a`).
* **Logging:**
  * Implemented a custom logging system (`e89d5c4`).

### Changed

* **Default Embedding Provider:** Changed the default embedding provider to Gemini (`1d70fb0`).
* **Configuration Refactor:** Refactored the configuration system to better support multiple providers with dedicated classes (`8a790fa`).
* **API Credentials:** Updated OpenAI and OpenRouter clients to use `access_token` (fetched from environment variables) instead of `api_key` (`e070672`).
* Removed internal `log_level` accessor (`1631a00`).

### Documentation

* Enhanced documentation and added examples for `Broca`, `Hippocampus`, and newly integrated modules/providers (`7c0f5e3`, `0bea02e`).

### Internal / Chores

* Updated gem dependencies and development tools (`e20a3f8`).
* General code cleanup and enforcement of frozen string literals (`1521e5b`).

*(Note: Commits related to merging (`4d132713`), specific packaging (`3f63e9c`), and adding individual gems (`b87428a`) were summarized or included within their respective feature descriptions.)*

## [0.1.0] - 2023-05-01

* Initial release
