import 'package:mimo_flutter_sdk_community/src/models/openai/openai_chunk.dart';
import 'package:test/test.dart';

void main() {
  group('OpenAIChunk', () {
    test('fromJson with content delta', () {
      final json = {
        'id': 'chatcmpl-123',
        'object': 'chat.completion.chunk',
        'created': 1677858042,
        'model': 'gpt-4',
        'choices': [
          {
            'index': 0,
            'delta': {'content': 'Hello'},
            'finish_reason': null,
          },
        ],
      };
      final chunk = OpenAIChunk.fromJson(json);
      expect(chunk.id, 'chatcmpl-123');
      expect(chunk.object, 'chat.completion.chunk');
      expect(chunk.created, 1677858042);
      expect(chunk.model, 'gpt-4');
      expect(chunk.choices, hasLength(1));
      expect(chunk.choices[0].index, 0);
      expect(chunk.choices[0].delta.content, 'Hello');
      expect(chunk.choices[0].finishReason, isNull);
    });

    test('fromJson with role delta', () {
      final json = {
        'id': 'chatcmpl-123',
        'object': 'chat.completion.chunk',
        'created': 1677858042,
        'model': 'gpt-4',
        'choices': [
          {
            'index': 0,
            'delta': {'role': 'assistant'},
            'finish_reason': null,
          },
        ],
      };
      final chunk = OpenAIChunk.fromJson(json);
      expect(chunk.choices[0].delta.role, 'assistant');
      expect(chunk.choices[0].delta.content, isNull);
    });

    test('fromJson with finish_reason', () {
      final json = {
        'id': 'chatcmpl-123',
        'object': 'chat.completion.chunk',
        'created': 1677858042,
        'model': 'gpt-4',
        'choices': [
          {
            'index': 0,
            'delta': <String, dynamic>{},
            'finish_reason': 'stop',
          },
        ],
      };
      final chunk = OpenAIChunk.fromJson(json);
      expect(chunk.choices[0].finishReason, 'stop');
    });

    test('fromJson with tool_calls delta', () {
      final json = {
        'id': 'chatcmpl-123',
        'object': 'chat.completion.chunk',
        'created': 1677858042,
        'model': 'gpt-4',
        'choices': [
          {
            'index': 0,
            'delta': {
              'tool_calls': [
                {
                  'id': 'call_1',
                  'type': 'function',
                  'function': {'name': 'fn', 'arguments': '{"a":1}'},
                },
              ],
            },
            'finish_reason': null,
          },
        ],
      };
      final chunk = OpenAIChunk.fromJson(json);
      expect(chunk.choices[0].delta.toolCalls, hasLength(1));
      expect(chunk.choices[0].delta.toolCalls![0].id, 'call_1');
    });

    test('fromJson with reasoning_content', () {
      final json = {
        'id': 'chatcmpl-123',
        'object': 'chat.completion.chunk',
        'created': 1677858042,
        'model': 'gpt-4',
        'choices': [
          {
            'index': 0,
            'delta': {'reasoning_content': 'Let me think...'},
            'finish_reason': null,
          },
        ],
      };
      final chunk = OpenAIChunk.fromJson(json);
      expect(chunk.choices[0].delta.reasoningContent, 'Let me think...');
    });

    test('fromJson with usage', () {
      final json = {
        'id': 'chatcmpl-123',
        'object': 'chat.completion.chunk',
        'created': 1677858042,
        'model': 'gpt-4',
        'choices': [],
        'usage': {
          'prompt_tokens': 10,
          'completion_tokens': 20,
          'total_tokens': 30,
        },
      };
      final chunk = OpenAIChunk.fromJson(json);
      expect(chunk.usage, isNotNull);
      expect(chunk.usage!.totalTokens, 30);
    });
  });

  group('OpenAIChunkChoice', () {
    test('fromJson', () {
      final json = {
        'index': 0,
        'delta': {'content': 'hi'},
        'finish_reason': 'stop',
      };
      final choice = OpenAIChunkChoice.fromJson(json);
      expect(choice.index, 0);
      expect(choice.delta.content, 'hi');
      expect(choice.finishReason, 'stop');
    });
  });

  group('OpenAIDelta', () {
    test('fromJson with all null fields', () {
      final json = <String, dynamic>{};
      final delta = OpenAIDelta.fromJson(json);
      expect(delta.role, isNull);
      expect(delta.content, isNull);
      expect(delta.reasoningContent, isNull);
      expect(delta.toolCalls, isNull);
      expect(delta.audio, isNull);
    });

    test('fromJson with audio delta', () {
      final json = {
        'audio': {
          'id': 'audio_1',
          'data': 'base64chunk',
          'transcript': 'partial',
        },
      };
      final delta = OpenAIDelta.fromJson(json);
      expect(delta.audio, isNotNull);
      expect(delta.audio!.id, 'audio_1');
      expect(delta.audio!.data, 'base64chunk');
      expect(delta.audio!.transcript, 'partial');
    });
  });

  group('OpenAIDeltaAudio', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 'audio_1',
        'data': 'data',
        'transcript': 'text',
      };
      final audio = OpenAIDeltaAudio.fromJson(json);
      expect(audio.id, 'audio_1');
      expect(audio.data, 'data');
      expect(audio.transcript, 'text');
    });

    test('fromJson with nulls', () {
      final audio = OpenAIDeltaAudio.fromJson({});
      expect(audio.id, isNull);
      expect(audio.data, isNull);
      expect(audio.transcript, isNull);
    });
  });
}
