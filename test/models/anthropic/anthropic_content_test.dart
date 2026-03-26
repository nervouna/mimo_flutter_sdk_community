import 'dart:convert';

import 'package:mimo_flutter_sdk_community/src/models/anthropic/anthropic_content.dart';
import 'package:test/test.dart';

void main() {
  group('AnthropicTextContent', () {
    test('toJson', () {
      const c = AnthropicTextContent('hello');
      expect(c.toJson(), {'type': 'text', 'text': 'hello'});
    });

    test('fromJson roundtrip', () {
      const original = AnthropicTextContent('world');
      final restored = AnthropicContent.fromJson(original.toJson());
      expect(restored, isA<AnthropicTextContent>());
      expect((restored as AnthropicTextContent).text, 'world');
    });
  });

  group('AnthropicThinkingContent', () {
    test('toJson', () {
      const c = AnthropicThinkingContent(
        thinking: 'Let me think...',
        signature: 'sig123',
      );
      expect(c.toJson(), {
        'type': 'thinking',
        'thinking': 'Let me think...',
        'signature': 'sig123',
      });
    });

    test('fromJson roundtrip', () {
      const original = AnthropicThinkingContent(
        thinking: 'reasoning',
        signature: 'sig',
      );
      final restored = AnthropicContent.fromJson(original.toJson());
      expect(restored, isA<AnthropicThinkingContent>());
      final t = restored as AnthropicThinkingContent;
      expect(t.thinking, 'reasoning');
      expect(t.signature, 'sig');
    });
  });

  group('AnthropicRedactedThinkingContent', () {
    test('toJson', () {
      const c = AnthropicRedactedThinkingContent('encrypted_data');
      expect(c.toJson(), {'type': 'redacted_thinking', 'data': 'encrypted_data'});
    });

    test('fromJson roundtrip', () {
      const original = AnthropicRedactedThinkingContent('abc');
      final restored = AnthropicContent.fromJson(original.toJson());
      expect(restored, isA<AnthropicRedactedThinkingContent>());
      expect((restored as AnthropicRedactedThinkingContent).data, 'abc');
    });
  });

  group('AnthropicToolUseContent', () {
    test('toJson', () {
      const c = AnthropicToolUseContent(
        id: 'toolu_123',
        name: 'get_weather',
        input: {'location': 'Beijing'},
      );
      expect(c.toJson(), {
        'type': 'tool_use',
        'id': 'toolu_123',
        'name': 'get_weather',
        'input': {'location': 'Beijing'},
      });
    });

    test('fromJson roundtrip', () {
      const original = AnthropicToolUseContent(
        id: 'toolu_1',
        name: 'fn',
        input: {'x': 1},
      );
      final restored = AnthropicContent.fromJson(original.toJson());
      expect(restored, isA<AnthropicToolUseContent>());
      final t = restored as AnthropicToolUseContent;
      expect(t.id, 'toolu_1');
      expect(t.name, 'fn');
      expect(t.input, {'x': 1});
    });
  });

  group('AnthropicToolResultContent', () {
    test('toJson with string content', () {
      const c = AnthropicToolResultContent(
        toolUseId: 'toolu_1',
        content: '{"temp": 72}',
      );
      final json = c.toJson();
      expect(json['type'], 'tool_result');
      expect(json['tool_use_id'], 'toolu_1');
      expect(json['content'], '{"temp": 72}');
      expect(json['is_error'], false);
    });

    test('toJson with list content', () {
      final c = AnthropicToolResultContent(
        toolUseId: 'toolu_1',
        content: [AnthropicTextContent('result')],
      );
      final json = c.toJson();
      expect(json['content'], isA<List>());
      expect(json['content'][0]['type'], 'text');
    });

    test('toJson with null content', () {
      final c = AnthropicToolResultContent(
        toolUseId: 'toolu_1',
        content: null,
      );
      final json = c.toJson();
      expect(json.containsKey('content'), isFalse);
    });

    test('toJson with isError', () {
      const c = AnthropicToolResultContent(
        toolUseId: 'toolu_1',
        content: 'error message',
        isError: true,
      );
      expect(c.toJson()['is_error'], true);
    });

    test('fromJson with string content', () {
      final json = {
        'type': 'tool_result',
        'tool_use_id': 'toolu_1',
        'content': 'result text',
        'is_error': false,
      };
      final restored = AnthropicContent.fromJson(json);
      expect(restored, isA<AnthropicToolResultContent>());
      final t = restored as AnthropicToolResultContent;
      expect(t.toolUseId, 'toolu_1');
      expect(t.content, 'result text');
      expect(t.isError, false);
    });

    test('fromJson with list content', () {
      final json = {
        'type': 'tool_result',
        'tool_use_id': 'toolu_1',
        'content': [
          {'type': 'text', 'text': 'hi'},
        ],
      };
      final restored = AnthropicContent.fromJson(json);
      expect(restored, isA<AnthropicToolResultContent>());
      final t = restored as AnthropicToolResultContent;
      expect(t.content, isA<List>());
    });
  });

  group('AnthropicImageContent', () {
    test('toJson', () {
      const c = AnthropicImageContent(
        type: 'base64',
        mediaType: 'image/png',
        data: 'base64data',
      );
      expect(c.toJson(), {
        'type': 'image',
        'source': {
          'type': 'base64',
          'media_type': 'image/png',
          'data': 'base64data',
        },
      });
    });

    test('fromJson roundtrip', () {
      const original = AnthropicImageContent(
        type: 'base64',
        mediaType: 'image/jpeg',
        data: 'abc',
      );
      final restored = AnthropicContent.fromJson(original.toJson());
      expect(restored, isA<AnthropicImageContent>());
      final img = restored as AnthropicImageContent;
      expect(img.type, 'base64');
      expect(img.mediaType, 'image/jpeg');
      expect(img.data, 'abc');
    });
  });

  group('AnthropicContent.fromJson', () {
    test('unknown type falls back to text with jsonEncode', () {
      final json = {'type': 'unknown_type', 'foo': 'bar'};
      final content = AnthropicContent.fromJson(json);
      expect(content, isA<AnthropicTextContent>());
      expect((content as AnthropicTextContent).text, jsonEncode(json));
    });
  });

  group('AnthropicContent factory constructors', () {
    test('.text', () {
      final c = AnthropicContent.text('hi');
      expect(c, isA<AnthropicTextContent>());
    });

    test('.thinking', () {
      final c = AnthropicContent.thinking(thinking: 't', signature: 's');
      expect(c, isA<AnthropicThinkingContent>());
    });

    test('.redactedThinking', () {
      final c = AnthropicContent.redactedThinking('data');
      expect(c, isA<AnthropicRedactedThinkingContent>());
    });

    test('.toolUse', () {
      final c = AnthropicContent.toolUse(id: '1', name: 'fn', input: {});
      expect(c, isA<AnthropicToolUseContent>());
    });

    test('.toolResult', () {
      final c = AnthropicContent.toolResult(toolUseId: '1', content: 'ok');
      expect(c, isA<AnthropicToolResultContent>());
    });

    test('.image', () {
      final c = AnthropicContent.image(
          type: 'base64', mediaType: 'image/png', data: 'd');
      expect(c, isA<AnthropicImageContent>());
    });
  });
}
