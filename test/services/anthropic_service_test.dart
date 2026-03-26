import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mimo_flutter_sdk_community/src/client/client_config.dart';
import 'package:mimo_flutter_sdk_community/src/errors/mimo_exception.dart';
import 'package:mimo_flutter_sdk_community/src/models/anthropic/anthropic_chunk.dart';
import 'package:mimo_flutter_sdk_community/src/models/anthropic/anthropic_request.dart';
import 'package:mimo_flutter_sdk_community/src/models/anthropic/anthropic_response.dart';
import 'package:mimo_flutter_sdk_community/src/services/anthropic_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockClient extends Mock implements http.Client {}

class MockStreamedResponse extends Mock implements http.StreamedResponse {}

void main() {
  late MockClient mockClient;
  late AnthropicService service;

  const config = MimoClientConfig(apiKey: 'test-key');

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
    registerFallbackValue(http.Request('POST', Uri.parse('https://example.com')));
  });

  setUp(() {
    mockClient = MockClient();
    service = AnthropicService(config: config, client: mockClient);
  });

  final messagesRequest = AnthropicMessagesRequest(
    model: 'mimo-v2-pro',
    maxTokens: 1024,
    messages: [AnthropicMessage.user('Hello')],
  );

  group('AnthropicService.messages', () {
    test('returns AnthropicMessagesResponse on success', () async {
      final responseBody = {
        'id': 'msg_1',
        'type': 'message',
        'role': 'assistant',
        'content': [
          {'type': 'text', 'text': 'Hi!'},
        ],
        'model': 'mimo-v2-pro',
        'stop_reason': 'end_turn',
        'usage': {
          'input_tokens': 5,
          'output_tokens': 3,
        },
      };

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response(jsonEncode(responseBody), 200),
      );

      final response = await service.messages(messagesRequest);
      expect(response, isA<AnthropicMessagesResponse>());
      expect(response.id, 'msg_1');
      expect(response.role, 'assistant');

      verify(() => mockClient.post(
            Uri.parse('https://api.xiaomimimo.com/anthropic/v1/messages'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);
    });

    test('uses anthropic format headers', () async {
      when(() => mockClient.post(
            any(),
            headers: captureAny(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'id': 'msg_1',
            'type': 'message',
            'role': 'assistant',
            'content': [],
            'model': 'm',
          }),
          200,
        ),
      );

      await service.messages(messagesRequest);

      final headers =
          verify(() => mockClient.post(any(),
              headers: captureAny(named: 'headers'),
              body: any(named: 'body'))).captured.single as Map<String, String>;
      expect(headers['x-api-key'], 'test-key');
      expect(headers['anthropic-version'], '2023-06-01');
    });

    test('sets stream=false in request body', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'id': 'msg_1',
            'type': 'message',
            'role': 'assistant',
            'content': [],
            'model': 'm',
          }),
          200,
        ),
      );

      await service.messages(messagesRequest);

      final captured =
          verify(() => mockClient.post(any(),
              headers: any(named: 'headers'),
              body: captureAny(named: 'body'))).captured.single as String;
      final body = jsonDecode(captured) as Map<String, dynamic>;
      expect(body['stream'], false);
    });

    test('throws MimoAuthenticationException on 401', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response('{"error":{"message":"Invalid"}}', 401),
      );

      expect(
        () => service.messages(messagesRequest),
        throwsA(isA<MimoAuthenticationException>()),
      );
    });

    test('throws MimoRateLimitException on 429', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response('{"message":"rate limit"}', 429),
      );

      expect(
        () => service.messages(messagesRequest),
        throwsA(isA<MimoRateLimitException>()),
      );
    });

    test('throws MimoServerException on 500', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response('Server Error', 500),
      );

      expect(
        () => service.messages(messagesRequest),
        throwsA(isA<MimoServerException>()),
      );
    });

    test('throws MimoNetworkException on ClientException', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenThrow(http.ClientException('Connection refused'));

      expect(
        () => service.messages(messagesRequest),
        throwsA(isA<MimoNetworkException>()),
      );
    });
  });

  group('AnthropicService.messagesStream', () {
    test('yields AnthropicStreamEvent on success', () async {
      final sseData =
          'event: message_start\ndata: {"type":"message_start","message":{"id":"msg_1","type":"message","role":"assistant","content":[],"model":"m"}}\n\n'
          'event: content_block_start\ndata: {"type":"content_block_start","index":0,"content_block":{"type":"text","text":""}}\n\n'
          'event: content_block_delta\ndata: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hi"}}\n\n'
          'event: content_block_stop\ndata: {"type":"content_block_stop","index":0}\n\n'
          'event: message_stop\ndata: {"type":"message_stop"}\n\n';

      final bytes = Stream<List<int>>.fromIterable([utf8.encode(sseData)]);

      when(() => mockClient.send(any())).thenAnswer(
        (_) async => http.StreamedResponse(bytes, 200),
      );

      final events = await service.messagesStream(messagesRequest).toList();
      expect(events, hasLength(5));
      expect(events[0], isA<AnthropicMessageStartEvent>());
      expect(events[1], isA<AnthropicContentBlockStartEvent>());
      expect(events[2], isA<AnthropicContentBlockDeltaEvent>());
      expect(events[3], isA<AnthropicContentBlockStopEvent>());
      expect(events[4], isA<AnthropicMessageStopEvent>());
    });

    test('throws on non-200 status', () async {
      final bytes = Stream<List<int>>.fromIterable([utf8.encode('Unauthorized')]);

      when(() => mockClient.send(any())).thenAnswer(
        (_) async => http.StreamedResponse(bytes, 401),
      );

      expect(
        () => service.messagesStream(messagesRequest).toList(),
        throwsA(isA<MimoAuthenticationException>()),
      );
    });

    test('throws MimoNetworkException on ClientException', () async {
      when(() => mockClient.send(any()))
          .thenThrow(http.ClientException('Network error'));

      expect(
        () => service.messagesStream(messagesRequest).toList(),
        throwsA(isA<MimoNetworkException>()),
      );
    });
  });
}
