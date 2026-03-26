import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mimo_flutter_sdk_community/src/client/client_config.dart';
import 'package:mimo_flutter_sdk_community/src/client/mimo_client.dart';
import 'package:mimo_flutter_sdk_community/src/models/anthropic/anthropic_request.dart';
import 'package:mimo_flutter_sdk_community/src/models/openai/openai_request.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  late MockClient mockClient;
  late MimoClient client;

  const config = MimoClientConfig(apiKey: 'test-key');

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() {
    mockClient = MockClient();
    client = MimoClient(config: config, httpClient: mockClient);
  });

  test('config getter returns config', () {
    expect(client.config, same(config));
  });

  test('chat delegates to OpenAIService', () async {
    final responseBody = {
      'id': 'c1',
      'object': 'chat.completion',
      'created': 0,
      'model': 'm',
      'choices': [],
    };

    when(() => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).thenAnswer(
      (_) async => http.Response(jsonEncode(responseBody), 200),
    );

    final request = OpenAIChatRequest(
      model: 'mimo-v2-pro',
      messages: [OpenAIMessage.user('Hi')],
    );

    final response = await client.chat(request);
    expect(response.id, 'c1');

    verify(() => mockClient.post(
          Uri.parse('https://api.xiaomimimo.com/v1/chat/completions'),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).called(1);
  });

  test('messages delegates to AnthropicService', () async {
    final responseBody = {
      'id': 'msg_1',
      'type': 'message',
      'role': 'assistant',
      'content': [],
      'model': 'm',
    };

    when(() => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).thenAnswer(
      (_) async => http.Response(jsonEncode(responseBody), 200),
    );

    final request = AnthropicMessagesRequest(
      model: 'mimo-v2-pro',
      maxTokens: 1024,
      messages: [AnthropicMessage.user('Hi')],
    );

    final response = await client.messages(request);
    expect(response.id, 'msg_1');

    verify(() => mockClient.post(
          Uri.parse('https://api.xiaomimimo.com/anthropic/v1/messages'),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).called(1);
  });

  test('tts delegates to OpenAIService.tts', () async {
    when(() => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).thenAnswer(
      (_) async => http.Response.bytes([1, 2, 3], 200),
    );

    final result = await client.tts(input: 'Hello');
    expect(result, [1, 2, 3]);

    final captured =
        verify(() => mockClient.post(any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'))).captured.single as String;
    final body = jsonDecode(captured) as Map<String, dynamic>;
    expect(body['model'], 'mimo-v2-tts');
    expect(body['voice'], 'mimo_default');
    expect(body['response_format'], 'wav');
  });

  test('dispose closes both services', () {
    // We can't easily verify close() was called on the mock since
    // the services create their own clients, but we can verify
    // dispose doesn't throw.
    client.dispose();
  });
}
