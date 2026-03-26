import 'package:mimo_flutter_sdk_community/src/models/openai/openai_request.dart';
import 'package:mimo_flutter_sdk_community/src/models/openai/openai_content.dart';
import 'package:mimo_flutter_sdk_community/src/models/openai/openai_tool.dart';
import 'package:test/test.dart';

void main() {
  group('OpenAIMessage', () {
    test('system factory', () {
      final msg = OpenAIMessage.system('You are helpful.');
      expect(msg.role, 'system');
      expect(msg.content, 'You are helpful.');
      expect(msg.name, isNull);
      expect(msg.toolCalls, isNull);
      expect(msg.toolCallId, isNull);
      expect(msg.reasoningContent, isNull);
    });

    test('developer factory', () {
      final msg = OpenAIMessage.developer('Dev note');
      expect(msg.role, 'developer');
      expect(msg.content, 'Dev note');
    });

    test('user factory', () {
      final msg = OpenAIMessage.user('Hello');
      expect(msg.role, 'user');
      expect(msg.content, 'Hello');
    });

    test('userContent factory', () {
      final parts = [
        const OpenAITextContent('describe this'),
        const OpenAIImageContent('https://img.png'),
      ];
      final msg = OpenAIMessage.userContent(parts);
      expect(msg.role, 'user');
      expect(msg.content, isA<List<OpenAIMessageContent>>());
      expect((msg.content as List), hasLength(2));
    });

    test('assistant factory with reasoningContent', () {
      final msg = OpenAIMessage.assistant(
        'The answer is 42.',
        reasoningContent: 'Let me think...',
      );
      expect(msg.role, 'assistant');
      expect(msg.content, 'The answer is 42.');
      expect(msg.reasoningContent, 'Let me think...');
    });

    test('tool factory', () {
      final msg = OpenAIMessage.tool(
        toolCallId: 'call_1',
        content: '{"temp": 72}',
      );
      expect(msg.role, 'tool');
      expect(msg.toolCallId, 'call_1');
      expect(msg.content, '{"temp": 72}');
    });

    test('toJson with string content', () {
      final msg = OpenAIMessage.user('hi');
      final json = msg.toJson();
      expect(json['role'], 'user');
      expect(json['content'], 'hi');
    });

    test('toJson with list content', () {
      final msg = OpenAIMessage.userContent([
        const OpenAITextContent('hello'),
      ]);
      final json = msg.toJson();
      expect(json['role'], 'user');
      expect(json['content'], isA<List>());
      expect(json['content'][0]['type'], 'text');
    });

    test('toJson includes optional fields', () {
      final msg = OpenAIMessage(
        role: 'assistant',
        content: 'ok',
        name: 'bot',
        reasoningContent: 'thinking',
      );
      final json = msg.toJson();
      expect(json['name'], 'bot');
      expect(json['reasoning_content'], 'thinking');
    });

    test('fromJson with string content', () {
      final json = {'role': 'user', 'content': 'hello'};
      final msg = OpenAIMessage.fromJson(json);
      expect(msg.role, 'user');
      expect(msg.content, 'hello');
    });

    test('fromJson with list content', () {
      final json = {
        'role': 'user',
        'content': [
          {'type': 'text', 'text': 'hi'},
        ],
      };
      final msg = OpenAIMessage.fromJson(json);
      expect(msg.content, isA<List<OpenAIMessageContent>>());
      expect((msg.content as List<OpenAIMessageContent>)[0],
          isA<OpenAITextContent>());
    });

    test('fromJson with tool_calls', () {
      final json = {
        'role': 'assistant',
        'content': null,
        'tool_calls': [
          {
            'id': 'call_1',
            'type': 'function',
            'function': {'name': 'fn', 'arguments': '{}'},
          },
        ],
      };
      final msg = OpenAIMessage.fromJson(json);
      expect(msg.role, 'assistant');
      expect(msg.toolCalls, hasLength(1));
      expect(msg.toolCalls![0].id, 'call_1');
    });

    test('fromJson/toJson roundtrip for text message', () {
      final original = OpenAIMessage.user('test roundtrip');
      final json = original.toJson();
      final restored = OpenAIMessage.fromJson(json);
      expect(restored.role, original.role);
      expect(restored.content, original.content);
    });
  });

  group('OpenAIChatRequest', () {
    test('toJson with minimal fields', () {
      final req = OpenAIChatRequest(
        model: 'gpt-4',
        messages: [OpenAIMessage.user('hi')],
      );
      final json = req.toJson();
      expect(json['model'], 'gpt-4');
      expect(json['messages'], hasLength(1));
      expect(json['stream'], false);
    });

    test('toJson includes all optional fields', () {
      final req = OpenAIChatRequest(
        model: 'gpt-4',
        messages: [OpenAIMessage.user('hi')],
        temperature: 0.7,
        topP: 0.9,
        maxCompletionTokens: 100,
        tools: [OpenAITool.function(name: 'fn')],
        toolChoice: const OpenAIToolChoice.auto(),
        responseFormat: const OpenAIResponseFormat.jsonObject(),
        thinking: const OpenAIThinkingConfig.enabled(),
        stream: true,
        audio: const OpenAIAudioConfig(format: 'wav', voice: 'alloy'),
        frequencyPenalty: 0.5,
        presencePenalty: 0.3,
        stop: ['\n'],
      );
      final json = req.toJson();
      expect(json['model'], 'gpt-4');
      expect(json['temperature'], 0.7);
      expect(json['top_p'], 0.9);
      expect(json['max_completion_tokens'], 100);
      expect(json['tools'], hasLength(1));
      expect(json['tool_choice'], 'auto');
      expect(json['response_format'], {'type': 'json_object'});
      expect(json['thinking'], {'type': 'enabled'});
      expect(json['stream'], true);
      expect(json['audio'], {'format': 'wav', 'voice': 'alloy'});
      expect(json['frequency_penalty'], 0.5);
      expect(json['presence_penalty'], 0.3);
      expect(json['stop'], ['\n']);
    });

    test('toJson omits null optional fields', () {
      final req = OpenAIChatRequest(
        model: 'gpt-4',
        messages: [OpenAIMessage.user('hi')],
      );
      final json = req.toJson();
      expect(json.containsKey('temperature'), isFalse);
      expect(json.containsKey('top_p'), isFalse);
      expect(json.containsKey('max_completion_tokens'), isFalse);
      expect(json.containsKey('tools'), isFalse);
      expect(json.containsKey('tool_choice'), isFalse);
      expect(json.containsKey('audio'), isFalse);
    });
  });

  group('OpenAIAudioConfig', () {
    test('toJson with defaults', () {
      const config = OpenAIAudioConfig();
      expect(config.toJson(), {'format': 'wav', 'voice': 'mimo_default'});
    });

    test('toJson with custom values', () {
      const config = OpenAIAudioConfig(format: 'mp3', voice: 'alloy');
      expect(config.toJson(), {'format': 'mp3', 'voice': 'alloy'});
    });
  });
}
