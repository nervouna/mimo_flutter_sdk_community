import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mimo_flutter_sdk_community/src/client/client_config.dart';
import 'package:mimo_flutter_sdk_community/src/errors/mimo_exception.dart';
import 'package:mimo_flutter_sdk_community/src/models/openai/openai_chunk.dart';
import 'package:mimo_flutter_sdk_community/src/models/openai/openai_request.dart';
import 'package:mimo_flutter_sdk_community/src/models/openai/openai_response.dart';
import 'package:mimo_flutter_sdk_community/src/services/openai_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockClient extends Mock implements http.Client {}

class MockStreamedResponse extends Mock implements http.StreamedResponse {}

void main() {
  late MockClient mockClient;
  late OpenAIService service;

  const config = MimoClientConfig(apiKey: 'test-key');

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
    registerFallbackValue(http.Request('POST', Uri.parse('https://example.com')));
  });

  setUp(() {
    mockClient = MockClient();
    service = OpenAIService(config: config, client: mockClient);
  });

  final chatRequest = OpenAIChatRequest(
    model: 'mimo-v2-pro',
    messages: [OpenAIMessage.user('Hello')],
  );

  group('OpenAIService.chat', () {
    test('returns OpenAIChatResponse on success', () async {
      final responseBody = {
        'id': 'chatcmpl-1',
        'object': 'chat.completion',
        'created': 1234567890,
        'model': 'mimo-v2-pro',
        'choices': [
          {
            'index': 0,
            'message': {'role': 'assistant', 'content': 'Hi!'},
            'finish_reason': 'stop',
          }
        ],
        'usage': {
          'prompt_tokens': 5,
          'completion_tokens': 3,
          'total_tokens': 8,
        },
      };

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response(jsonEncode(responseBody), 200),
      );

      final response = await service.chat(chatRequest);
      expect(response, isA<OpenAIChatResponse>());
      expect(response.id, 'chatcmpl-1');
      expect(response.choices, hasLength(1));

      verify(() => mockClient.post(
            Uri.parse('https://api.xiaomimimo.com/v1/chat/completions'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);
    });

    test('throws MimoAuthenticationException on 401', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response(
          '{"error":{"message":"Invalid API key"}}',
          401,
        ),
      );

      expect(
        () => service.chat(chatRequest),
        throwsA(isA<MimoAuthenticationException>()),
      );
    });

    test('throws MimoRateLimitException on 429', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response(
          '{"message":"Rate limited"}',
          429,
          headers: {'retry-after': '10'},
        ),
      );

      expect(
        () => service.chat(chatRequest),
        throwsA(isA<MimoRateLimitException>()),
      );
    });

    test('throws MimoServerException on 500', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response('Internal Server Error', 500),
      );

      expect(
        () => service.chat(chatRequest),
        throwsA(isA<MimoServerException>()),
      );
    });

    test('throws MimoApiException on 400', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response(
          '{"error":{"message":"Bad request"}}',
          400,
        ),
      );

      expect(
        () => service.chat(chatRequest),
        throwsA(isA<MimoApiException>()),
      );
    });

    test('throws MimoNetworkException on ClientException', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenThrow(http.ClientException('Connection refused'));

      expect(
        () => service.chat(chatRequest),
        throwsA(isA<MimoNetworkException>()),
      );
    });

    test('sets stream=false in request body', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'id': 'c1',
            'object': 'chat.completion',
            'created': 0,
            'model': 'm',
            'choices': [],
          }),
          200,
        ),
      );

      await service.chat(chatRequest);

      final captured =
          verify(() => mockClient.post(any(),
              headers: any(named: 'headers'),
              body: captureAny(named: 'body'))).captured.single as String;
      final body = jsonDecode(captured) as Map<String, dynamic>;
      expect(body['stream'], false);
    });
  });

  group('OpenAIService.chatStream', () {
    test('yields OpenAIChunk events on success', () async {
      final sseData = 'data: {"id":"c1","object":"chat.completion.chunk","created":0,"model":"m","choices":[{"index":0,"delta":{"content":"Hi"},"finish_reason":null}]}\n\ndata: [DONE]\n\n';
      final bytes = Stream<List<int>>.fromIterable([utf8.encode(sseData)]);

      when(() => mockClient.send(any())).thenAnswer(
        (_) async => http.StreamedResponse(bytes, 200),
      );

      final chunks = await service.chatStream(chatRequest).toList();
      expect(chunks, hasLength(1));
      expect(chunks[0], isA<OpenAIChunk>());
      expect(chunks[0].id, 'c1');
    });

    test('throws on non-200 status', () async {
      final bytes = Stream<List<int>>.fromIterable([utf8.encode('Unauthorized')]);

      when(() => mockClient.send(any())).thenAnswer(
        (_) async => http.StreamedResponse(bytes, 401),
      );

      expect(
        () => service.chatStream(chatRequest).toList(),
        throwsA(isA<MimoAuthenticationException>()),
      );
    });

    test('throws MimoNetworkException on ClientException', () async {
      when(() => mockClient.send(any()))
          .thenThrow(http.ClientException('Network error'));

      expect(
        () => service.chatStream(chatRequest).toList(),
        throwsA(isA<MimoNetworkException>()),
      );
    });
  });

  group('OpenAIService.tts', () {
    test('returns audio bytes on success', () async {
      final audioBytes = [1, 2, 3, 4, 5];

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response.bytes(audioBytes, 200),
      );

      final result = await service.tts(
        model: 'mimo-v2-tts',
        input: 'Hello',
      );
      expect(result, audioBytes);
    });

    test('throws on non-200 status', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response('Bad request', 400),
      );

      expect(
        () => service.tts(model: 'mimo-v2-tts', input: 'Hello'),
        throwsA(isA<MimoApiException>()),
      );
    });

    test('sends correct body', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response.bytes([], 200),
      );

      await service.tts(
        model: 'mimo-v2-tts',
        input: 'Hello world',
        voice: 'default_zh',
        format: 'pcm16',
      );

      final captured =
          verify(() => mockClient.post(any(),
              headers: any(named: 'headers'),
              body: captureAny(named: 'body'))).captured.single as String;
      final body = jsonDecode(captured) as Map<String, dynamic>;
      expect(body['model'], 'mimo-v2-tts');
      expect(body['input'], 'Hello world');
      expect(body['voice'], 'default_zh');
      expect(body['response_format'], 'pcm16');
    });
  });
}
