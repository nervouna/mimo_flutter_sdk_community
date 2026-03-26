import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/client_config.dart';
import '../errors/error_mapper.dart';
import '../models/openai/openai_chunk.dart';
import '../models/openai/openai_request.dart';
import '../models/openai/openai_response.dart';
import '../transport/sse_parser.dart';

/// Service for the OpenAI-compatible chat completions endpoint.
class OpenAIService {
  OpenAIService({required MimoClientConfig config, http.Client? client})
      : _config = config,
        _client = client ?? http.Client();

  final MimoClientConfig _config;
  final http.Client _client;

  /// Non-streaming chat completion.
  Future<OpenAIChatResponse> chat(OpenAIChatRequest request) async {
    final body = request.toJson();
    body['stream'] = false;

    final uri = Uri.parse('${_config.baseUrl}/v1/chat/completions');
    try {
      final response = await _client
          .post(uri, headers: _config.buildHeaders(), body: jsonEncode(body))
          .timeout(_config.receiveTimeout);

      if (response.statusCode != 200) {
        throw ErrorMapper.fromResponse(response);
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return OpenAIChatResponse.fromJson(json);
    } on http.ClientException catch (e) {
      throw ErrorMapper.fromClientException(e);
    }
  }

  /// Streaming chat completion.
  Stream<OpenAIChunk> chatStream(OpenAIChatRequest request) async* {
    final body = request.toJson();
    body['stream'] = true;

    final uri = Uri.parse('${_config.baseUrl}/v1/chat/completions');
    final httpRequest = http.Request('POST', uri)
      ..headers.addAll(_config.buildHeaders())
      ..body = jsonEncode(body);

    try {
      final streamedResponse =
          await _client.send(httpRequest).timeout(_config.receiveTimeout);

      if (streamedResponse.statusCode != 200) {
        final body = await streamedResponse.stream.bytesToString();
        final fakeResponse = http.Response(body, streamedResponse.statusCode,
            headers: streamedResponse.headers);
        throw ErrorMapper.fromResponse(fakeResponse);
      }

      yield* OpenAISseParser.parse(streamedResponse.stream)
          .map((json) => OpenAIChunk.fromJson(json));
    } on http.ClientException catch (e) {
      throw ErrorMapper.fromClientException(e);
    }
  }

  /// Text-to-speech: returns audio bytes (wav/pcm16).
  Future<List<int>> tts({
    required String model,
    required String input,
    String voice = 'mimo_default',
    String format = 'wav',
  }) async {
    final body = {
      'model': model,
      'input': input,
      'voice': voice,
      'response_format': format,
    };

    final uri = Uri.parse('${_config.baseUrl}/v1/audio/speech');
    try {
      final response = await _client
          .post(uri, headers: _config.buildHeaders(), body: jsonEncode(body))
          .timeout(_config.receiveTimeout);

      if (response.statusCode != 200) {
        throw ErrorMapper.fromResponse(response);
      }

      return response.bodyBytes;
    } on http.ClientException catch (e) {
      throw ErrorMapper.fromClientException(e);
    }
  }

  void dispose() {
    _client.close();
  }
}
