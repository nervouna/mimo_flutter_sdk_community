# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-27

### Added

- OpenAI-compatible chat completion with `MimoClient.chat()`
- Anthropic-compatible messages with `MimoClient.messages()`
- SSE streaming for both OpenAI and Anthropic endpoints
- Tool use / function calling support
- Multimodal input (image + text)
- Text-to-speech (TTS) generation
- Thinking mode (chain-of-thought) for both endpoints
- Web search tool integration
- Structured output with JSON mode
- Configurable base URL, API key, and timeout
- Custom HTTP client injection
- Comprehensive error hierarchy with `MimoException`
