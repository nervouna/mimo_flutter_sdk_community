import 'package:mimo_flutter_sdk_community/src/models/anthropic/anthropic_chunk.dart';
import 'package:mimo_flutter_sdk_community/src/models/anthropic/anthropic_content.dart';
import 'package:test/test.dart';

void main() {
  group('AnthropicStreamEvent.fromJson', () {
    test('message_start', () {
      final json = {
        'type': 'message_start',
        'message': {
          'id': 'msg_1',
          'type': 'message',
          'role': 'assistant',
          'content': [],
          'model': 'claude-3',
          'stop_reason': null,
        },
      };
      final event = AnthropicStreamEvent.fromJson(json);
      expect(event, isA<AnthropicMessageStartEvent>());
      expect(event.type, 'message_start');
      expect((event as AnthropicMessageStartEvent).message.id, 'msg_1');
    });

    test('message_delta', () {
      final json = {
        'type': 'message_delta',
        'delta': {
          'stop_reason': 'end_turn',
          'stop_sequence': null,
        },
        'usage': {
          'output_tokens': 42,
        },
      };
      final event = AnthropicStreamEvent.fromJson(json);
      expect(event, isA<AnthropicMessageDeltaEvent>());
      final e = event as AnthropicMessageDeltaEvent;
      expect(e.delta.stopReason, 'end_turn');
      expect(e.usage, isNotNull);
      expect(e.usage!.outputTokens, 42);
    });

    test('message_stop', () {
      final json = {'type': 'message_stop'};
      final event = AnthropicStreamEvent.fromJson(json);
      expect(event, isA<AnthropicMessageStopEvent>());
      expect(event.type, 'message_stop');
    });

    test('content_block_start', () {
      final json = {
        'type': 'content_block_start',
        'index': 0,
        'content_block': {'type': 'text', 'text': ''},
      };
      final event = AnthropicStreamEvent.fromJson(json);
      expect(event, isA<AnthropicContentBlockStartEvent>());
      final e = event as AnthropicContentBlockStartEvent;
      expect(e.index, 0);
      expect(e.contentBlock, isA<AnthropicTextContent>());
    });

    test('content_block_delta with text_delta', () {
      final json = {
        'type': 'content_block_delta',
        'index': 0,
        'delta': {'type': 'text_delta', 'text': 'Hello'},
      };
      final event = AnthropicStreamEvent.fromJson(json);
      expect(event, isA<AnthropicContentBlockDeltaEvent>());
      final e = event as AnthropicContentBlockDeltaEvent;
      expect(e.index, 0);
      expect(e.delta, isA<AnthropicTextDelta>());
      expect((e.delta as AnthropicTextDelta).text, 'Hello');
    });

    test('content_block_stop', () {
      final json = {
        'type': 'content_block_stop',
        'index': 1,
      };
      final event = AnthropicStreamEvent.fromJson(json);
      expect(event, isA<AnthropicContentBlockStopEvent>());
      expect((event as AnthropicContentBlockStopEvent).index, 1);
    });

    test('ping', () {
      final json = {'type': 'ping'};
      final event = AnthropicStreamEvent.fromJson(json);
      expect(event, isA<AnthropicPingEvent>());
      expect(event.type, 'ping');
    });

    test('error', () {
      final json = {
        'type': 'error',
        'error': {'type': 'overloaded', 'message': 'Too many requests'},
      };
      final event = AnthropicStreamEvent.fromJson(json);
      expect(event, isA<AnthropicErrorEvent>());
      final e = event as AnthropicErrorEvent;
      expect(e.error.type, 'overloaded');
      expect(e.error.message, 'Too many requests');
    });

    test('input_json_delta', () {
      final json = {
        'type': 'input_json_delta',
        'partial_json': '{"loc":',
      };
      final event = AnthropicStreamEvent.fromJson(json);
      expect(event, isA<AnthropicInputJsonDeltaEvent>());
      expect((event as AnthropicInputJsonDeltaEvent).partialJson, '{"loc":');
    });

    test('unknown event type', () {
      final json = {'type': 'future_event', 'foo': 'bar'};
      final event = AnthropicStreamEvent.fromJson(json);
      expect(event, isA<AnthropicUnknownEvent>());
      expect((event as AnthropicUnknownEvent).eventType, 'future_event');
    });
  });

  group('AnthropicContentDelta', () {
    test('text_delta', () {
      final json = {'type': 'text_delta', 'text': 'hello'};
      final delta = AnthropicContentDelta.fromJson(json);
      expect(delta, isA<AnthropicTextDelta>());
      expect((delta as AnthropicTextDelta).text, 'hello');
      expect(delta.type, 'text_delta');
    });

    test('thinking_delta', () {
      final json = {'type': 'thinking_delta', 'thinking': 'reasoning'};
      final delta = AnthropicContentDelta.fromJson(json);
      expect(delta, isA<AnthropicThinkingDelta>());
      expect((delta as AnthropicThinkingDelta).thinking, 'reasoning');
    });

    test('signature_delta', () {
      final json = {'type': 'signature_delta', 'signature': 'sig123'};
      final delta = AnthropicContentDelta.fromJson(json);
      expect(delta, isA<AnthropicSignatureDelta>());
      expect((delta as AnthropicSignatureDelta).signature, 'sig123');
    });

    test('input_json_delta', () {
      final json = {'type': 'input_json_delta', 'partial_json': '{"x":1}'};
      final delta = AnthropicContentDelta.fromJson(json);
      expect(delta, isA<AnthropicInputJsonDelta>());
      expect((delta as AnthropicInputJsonDelta).partialJson, '{"x":1}');
    });

    test('unknown delta type', () {
      final json = {'type': 'future_delta', 'data': 'something'};
      final delta = AnthropicContentDelta.fromJson(json);
      expect(delta, isA<AnthropicUnknownDelta>());
      expect((delta as AnthropicUnknownDelta).type, 'future_delta');
    });
  });

  group('AnthropicMessageDelta', () {
    test('fromJson', () {
      final json = {
        'stop_reason': 'end_turn',
        'stop_sequence': '',
      };
      final delta = AnthropicMessageDelta.fromJson(json);
      expect(delta.stopReason, 'end_turn');
      expect(delta.stopSequence, '');
    });

    test('fromJson with nulls', () {
      final delta = AnthropicMessageDelta.fromJson({});
      expect(delta.stopReason, isNull);
      expect(delta.stopSequence, isNull);
    });
  });

  group('AnthropicError', () {
    test('fromJson', () {
      final json = {'type': 'invalid_request', 'message': 'Bad request'};
      final error = AnthropicError.fromJson(json);
      expect(error.type, 'invalid_request');
      expect(error.message, 'Bad request');
    });
  });
}
