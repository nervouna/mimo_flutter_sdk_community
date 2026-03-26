import 'package:mimo_flutter_sdk_community/src/models/anthropic/anthropic_request.dart';
import 'package:mimo_flutter_sdk_community/src/models/anthropic/anthropic_content.dart';
import 'package:mimo_flutter_sdk_community/src/models/anthropic/anthropic_tool.dart';
import 'package:test/test.dart';

void main() {
  group('AnthropicMessage', () {
    test('user factory', () {
      final msg = AnthropicMessage.user('Hello');
      expect(msg.role, 'user');
      expect(msg.content, hasLength(1));
      expect(msg.content[0], isA<AnthropicTextContent>());
      expect((msg.content[0] as AnthropicTextContent).text, 'Hello');
    });

    test('userBlocks factory', () {
      final blocks = [
        AnthropicTextContent('describe this'),
        const AnthropicImageContent(
          type: 'base64',
          mediaType: 'image/png',
          data: 'abc',
        ),
      ];
      final msg = AnthropicMessage.userBlocks(blocks);
      expect(msg.role, 'user');
      expect(msg.content, hasLength(2));
    });

    test('assistant factory', () {
      final msg = AnthropicMessage.assistant('Hi there');
      expect(msg.role, 'assistant');
      expect(msg.content, hasLength(1));
      expect((msg.content[0] as AnthropicTextContent).text, 'Hi there');
    });

    test('assistantBlocks factory', () {
      final blocks = [
        const AnthropicThinkingContent(thinking: 't', signature: 's'),
        AnthropicTextContent('answer'),
      ];
      final msg = AnthropicMessage.assistantBlocks(blocks);
      expect(msg.role, 'assistant');
      expect(msg.content, hasLength(2));
    });

    test('toJson', () {
      final msg = AnthropicMessage.user('hi');
      final json = msg.toJson();
      expect(json['role'], 'user');
      expect(json['content'], hasLength(1));
      expect(json['content'][0]['type'], 'text');
    });

    test('fromJson with string content', () {
      final json = {'role': 'user', 'content': 'hello'};
      final msg = AnthropicMessage.fromJson(json);
      expect(msg.role, 'user');
      expect(msg.content, hasLength(1));
      expect(msg.content[0], isA<AnthropicTextContent>());
    });

    test('fromJson with list content', () {
      final json = {
        'role': 'assistant',
        'content': [
          {'type': 'text', 'text': 'hello'},
        ],
      };
      final msg = AnthropicMessage.fromJson(json);
      expect(msg.role, 'assistant');
      expect(msg.content, hasLength(1));
      expect(msg.content[0], isA<AnthropicTextContent>());
    });

    test('fromJson with null/other content', () {
      final json = {'role': 'assistant', 'content': null};
      final msg = AnthropicMessage.fromJson(json);
      expect(msg.content, isEmpty);
    });

    test('fromJson/toJson roundtrip', () {
      final original = AnthropicMessage.user('test');
      final restored = AnthropicMessage.fromJson(original.toJson());
      expect(restored.role, original.role);
      expect((restored.content[0] as AnthropicTextContent).text,
          (original.content[0] as AnthropicTextContent).text);
    });
  });

  group('AnthropicMessagesRequest', () {
    test('toJson with minimal fields', () {
      final req = AnthropicMessagesRequest(
        model: 'claude-3',
        maxTokens: 1024,
        messages: [AnthropicMessage.user('hi')],
      );
      final json = req.toJson();
      expect(json['model'], 'claude-3');
      expect(json['max_tokens'], 1024);
      expect(json['messages'], hasLength(1));
      expect(json['stream'], false);
    });

    test('toJson with string system', () {
      final req = AnthropicMessagesRequest(
        model: 'claude-3',
        maxTokens: 1024,
        messages: [AnthropicMessage.user('hi')],
        system: 'You are helpful.',
      );
      final json = req.toJson();
      expect(json['system'], 'You are helpful.');
    });

    test('toJson with list system', () {
      final req = AnthropicMessagesRequest(
        model: 'claude-3',
        maxTokens: 1024,
        messages: [AnthropicMessage.user('hi')],
        system: [AnthropicTextContent('System prompt')],
      );
      final json = req.toJson();
      expect(json['system'], isA<List>());
      expect(json['system'][0]['type'], 'text');
    });

    test('toJson includes all optional fields', () {
      final req = AnthropicMessagesRequest(
        model: 'claude-3',
        maxTokens: 1024,
        messages: [AnthropicMessage.user('hi')],
        temperature: 0.7,
        topP: 0.9,
        topK: 5,
        tools: [const AnthropicTool(name: 'fn')],
        toolChoice: const AnthropicToolChoice.auto(),
        thinking: const AnthropicThinkingConfig.disabled(),
        stream: true,
        stopSequences: ['\n'],
      );
      final json = req.toJson();
      expect(json['temperature'], 0.7);
      expect(json['top_p'], 0.9);
      expect(json['top_k'], 5);
      expect(json['tools'], hasLength(1));
      expect(json['tool_choice'], {'type': 'auto'});
      expect(json['thinking'], {'type': 'disabled'});
      expect(json['stream'], true);
      expect(json['stop_sequences'], ['\n']);
    });

    test('toJson omits null optional fields', () {
      final req = AnthropicMessagesRequest(
        model: 'claude-3',
        maxTokens: 1024,
        messages: [AnthropicMessage.user('hi')],
      );
      final json = req.toJson();
      expect(json.containsKey('system'), isFalse);
      expect(json.containsKey('temperature'), isFalse);
      expect(json.containsKey('top_p'), isFalse);
      expect(json.containsKey('tools'), isFalse);
      expect(json.containsKey('tool_choice'), isFalse);
      expect(json.containsKey('thinking'), isFalse);
      expect(json.containsKey('stop_sequences'), isFalse);
    });
  });

  group('AnthropicThinkingConfig', () {
    test('enabled with budgetTokens', () {
      const tc = AnthropicThinkingConfig.enabled(budgetTokens: 2048);
      final json = tc.toJson();
      expect(json['type'], 'enabled');
      expect(json['budget_tokens'], 2048);
    });

    test('enabled without budgetTokens', () {
      const tc = AnthropicThinkingConfig.enabled();
      final json = tc.toJson();
      expect(json['type'], 'enabled');
      expect(json.containsKey('budget_tokens'), isFalse);
    });

    test('disabled', () {
      const tc = AnthropicThinkingConfig.disabled();
      final json = tc.toJson();
      expect(json, {'type': 'disabled'});
    });
  });
}
