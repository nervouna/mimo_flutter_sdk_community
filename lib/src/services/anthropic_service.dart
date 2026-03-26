import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/client_config.dart';
import '../errors/error_mapper.dart';
import '../models/anthropic/anthropic_chunk.dart';
import '../models/common.dart';
import '../models/anthropic/anthropic_request.dart';
import '../models/anthropic/anthropic_response.dart';
import '../transport/sse_parser.dart';

/// Service for the Anthropic-compatible messages endpoint.
class AnthropicService {
  AnthropicService({required MimoClientConfig config, http.Client? client})
      : _config = config,
        _client = client ?? http.Client();

  final MimoClientConfig _config;
  final http.Client _client;

  /// Non-streaming messages completion.
  Future<AnthropicMessagesResponse> messages(
      AnthropicMessagesRequest request) async {
    final body = request.toJson();
    body['stream'] = false;

    final uri = Uri.parse('${_config.baseUrl}/anthropic/v1/messages');
    try {
      final response = await _client
          .post(uri,
              headers: _config.buildHeaders(format: MimoApiFormat.anthropic),
              body: jsonEncode(body))
          .timeout(_config.receiveTimeout);

      if (response.statusCode != 200) {
        throw ErrorMapper.fromResponse(response);
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AnthropicMessagesResponse.fromJson(json);
    } on http.ClientException catch (e) {
      throw ErrorMapper.fromClientException(e);
    }
  }

  /// Streaming messages completion.
  Stream<AnthropicStreamEvent> messagesStream(
      AnthropicMessagesRequest request) async* {
    final body = request.toJson();
    body['stream'] = true;

    final uri = Uri.parse('${_config.baseUrl}/anthropic/v1/messages');
    final httpRequest = http.Request('POST', uri)
      ..headers
          .addAll(_config.buildHeaders(format: MimoApiFormat.anthropic))
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

      yield* AnthropicSseParser.parse(streamedResponse.stream).map(
        (data) => AnthropicStreamEvent.fromJson(data.json),
      );
    } on http.ClientException catch (e) {
      throw ErrorMapper.fromClientException(e);
    }
  }

  void dispose() {
    _client.close();
  }
}
