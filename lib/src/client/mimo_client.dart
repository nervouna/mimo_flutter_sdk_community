import 'dart:async';

import 'package:http/http.dart' as http;

import '../models/anthropic/anthropic_chunk.dart';
import '../models/anthropic/anthropic_request.dart';
import '../models/anthropic/anthropic_response.dart';
import '../models/common.dart';
import '../models/openai/openai_chunk.dart';
import '../models/openai/openai_request.dart';
import '../models/openai/openai_response.dart';
import '../services/anthropic_service.dart';
import '../services/openai_service.dart';
import 'client_config.dart';

/// Unified client for the Xiaomi MIMO LLM API.
///
/// Supports both OpenAI-compatible and Anthropic-compatible endpoints.
///
/// ```dart
/// final client = MimoClient(config: MimoClientConfig(apiKey: 'your-key'));
///
/// // OpenAI format
/// final response = await client.chat(OpenAIChatRequest(
///   model: 'mimo-v2-pro',
///   messages: [OpenAIMessage.user('Hello')],
/// ));
///
/// // Anthropic format
/// final response = await client.messages(AnthropicMessagesRequest(
///   model: 'mimo-v2-pro',
///   maxTokens: 1024,
///   messages: [AnthropicMessage.user('Hello')],
/// ));
/// ```
class MimoClient {
  MimoClient({required MimoClientConfig config, http.Client? httpClient})
      : _config = config,
        _openaiService = OpenAIService(config: config, client: httpClient),
        _anthropicService = AnthropicService(config: config, client: httpClient);

  final MimoClientConfig _config;
  final OpenAIService _openaiService;
  final AnthropicService _anthropicService;

  /// The client configuration.
  MimoClientConfig get config => _config;

  // ─── OpenAI-compatible endpoints ────────────────────────────────────

  /// Non-streaming chat completion (OpenAI format).
  Future<OpenAIChatResponse> chat(OpenAIChatRequest request) {
    return _openaiService.chat(request);
  }

  /// Streaming chat completion (OpenAI format).
  Stream<OpenAIChunk> chatStream(OpenAIChatRequest request) {
    return _openaiService.chatStream(request);
  }

  /// Text-to-speech: returns audio bytes.
  Future<List<int>> tts({
    required String input,
    MimoModel model = MimoModel.mimoV2Tts,
    TtsVoice voice = TtsVoice.mimoDefault,
    TtsAudioFormat format = TtsAudioFormat.wav,
  }) {
    return _openaiService.tts(
      model: model.id,
      input: input,
      voice: voice.value,
      format: format.value,
    );
  }

  // ─── Anthropic-compatible endpoints ────────────────────────────────

  /// Non-streaming messages completion (Anthropic format).
  Future<AnthropicMessagesResponse> messages(AnthropicMessagesRequest request) {
    return _anthropicService.messages(request);
  }

  /// Streaming messages completion (Anthropic format).
  Stream<AnthropicStreamEvent> messagesStream(AnthropicMessagesRequest request) {
    return _anthropicService.messagesStream(request);
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────

  /// Close the underlying HTTP client.
  void dispose() {
    _openaiService.dispose();
    _anthropicService.dispose();
  }
}
