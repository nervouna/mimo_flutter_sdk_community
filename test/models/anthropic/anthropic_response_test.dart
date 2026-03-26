import 'package:mimo_flutter_sdk_community/src/models/anthropic/anthropic_response.dart';
import 'package:mimo_flutter_sdk_community/src/models/anthropic/anthropic_content.dart';
import 'package:test/test.dart';

void main() {
  group('AnthropicMessagesResponse', () {
    test('fromJson with full response', () {
      final json = {
        'id': 'msg_123',
        'type': 'message',
        'role': 'assistant',
        'content': [
          {'type': 'text', 'text': 'Hello!'},
        ],
        'model': 'claude-3-opus',
        'stop_reason': 'end_turn',
        'stop_sequence': null,
        'usage': {
          'input_tokens': 10,
          'output_tokens': 5,
        },
      };
      final resp = AnthropicMessagesResponse.fromJson(json);
      expect(resp.id, 'msg_123');
      expect(resp.type, 'message');
      expect(resp.role, 'assistant');
      expect(resp.content, hasLength(1));
      expect(resp.content[0], isA<AnthropicTextContent>());
      expect((resp.content[0] as AnthropicTextContent).text, 'Hello!');
      expect(resp.model, 'claude-3-opus');
      expect(resp.stopReason, 'end_turn');
      expect(resp.stopSequence, isNull);
      expect(resp.usage, isNotNull);
      expect(resp.usage!.inputTokens, 10);
      expect(resp.usage!.outputTokens, 5);
    });

    test('fromJson without usage', () {
      final json = {
        'id': 'msg_456',
        'type': 'message',
        'role': 'assistant',
        'content': [
          {'type': 'text', 'text': 'Hi'},
        ],
        'model': 'claude-3',
        'stop_reason': null,
      };
      final resp = AnthropicMessagesResponse.fromJson(json);
      expect(resp.usage, isNull);
      expect(resp.stopReason, isNull);
    });

    test('fromJson with thinking content', () {
      final json = {
        'id': 'msg_789',
        'type': 'message',
        'role': 'assistant',
        'content': [
          {'type': 'thinking', 'thinking': 'Let me think...', 'signature': 'sig'},
          {'type': 'text', 'text': 'The answer is 42.'},
        ],
        'model': 'claude-3',
        'stop_reason': 'end_turn',
      };
      final resp = AnthropicMessagesResponse.fromJson(json);
      expect(resp.content, hasLength(2));
      expect(resp.content[0], isA<AnthropicThinkingContent>());
      expect(resp.content[1], isA<AnthropicTextContent>());
    });
  });

  group('AnthropicUsage', () {
    test('fromJson with all fields', () {
      final json = {
        'input_tokens': 100,
        'output_tokens': 50,
        'cache_creation_input_tokens': 10,
        'cache_read_input_tokens': 20,
      };
      final usage = AnthropicUsage.fromJson(json);
      expect(usage.inputTokens, 100);
      expect(usage.outputTokens, 50);
      expect(usage.cacheCreationInputTokens, 10);
      expect(usage.cacheReadInputTokens, 20);
    });

    test('fromJson with nulls', () {
      final usage = AnthropicUsage.fromJson({});
      expect(usage.inputTokens, isNull);
      expect(usage.outputTokens, isNull);
      expect(usage.cacheCreationInputTokens, isNull);
      expect(usage.cacheReadInputTokens, isNull);
    });

    test('fromJson with only required fields', () {
      final json = {
        'input_tokens': 10,
        'output_tokens': 5,
      };
      final usage = AnthropicUsage.fromJson(json);
      expect(usage.inputTokens, 10);
      expect(usage.outputTokens, 5);
      expect(usage.cacheCreationInputTokens, isNull);
      expect(usage.cacheReadInputTokens, isNull);
    });
  });
}
