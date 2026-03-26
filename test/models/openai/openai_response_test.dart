import 'package:mimo_flutter_sdk_community/src/models/openai/openai_response.dart';
import 'package:test/test.dart';

void main() {
  group('OpenAIChatResponse', () {
    test('fromJson with full response', () {
      final json = {
        'id': 'chatcmpl-123',
        'object': 'chat.completion',
        'created': 1677858042,
        'model': 'gpt-4',
        'choices': [
          {
            'index': 0,
            'message': {'role': 'assistant', 'content': 'Hello!'},
            'finish_reason': 'stop',
          },
        ],
        'usage': {
          'prompt_tokens': 10,
          'completion_tokens': 5,
          'total_tokens': 15,
        },
      };
      final resp = OpenAIChatResponse.fromJson(json);
      expect(resp.id, 'chatcmpl-123');
      expect(resp.object, 'chat.completion');
      expect(resp.created, 1677858042);
      expect(resp.model, 'gpt-4');
      expect(resp.choices, hasLength(1));
      expect(resp.choices[0].index, 0);
      expect(resp.choices[0].message.role, 'assistant');
      expect(resp.choices[0].message.content, 'Hello!');
      expect(resp.choices[0].finishReason, 'stop');
      expect(resp.usage, isNotNull);
      expect(resp.usage!.promptTokens, 10);
      expect(resp.usage!.completionTokens, 5);
      expect(resp.usage!.totalTokens, 15);
    });

    test('fromJson without usage', () {
      final json = {
        'id': 'chatcmpl-456',
        'object': 'chat.completion',
        'created': 1677858042,
        'model': 'gpt-4',
        'choices': [
          {
            'index': 0,
            'message': {'role': 'assistant', 'content': 'Hi'},
            'finish_reason': null,
          },
        ],
      };
      final resp = OpenAIChatResponse.fromJson(json);
      expect(resp.usage, isNull);
      expect(resp.choices[0].finishReason, isNull);
    });

    test('fromJson with audio', () {
      final json = {
        'id': 'chatcmpl-789',
        'object': 'chat.completion',
        'created': 1677858042,
        'model': 'gpt-4o-audio-preview',
        'choices': [
          {
            'index': 0,
            'message': {'role': 'assistant', 'content': null},
            'finish_reason': 'stop',
          },
        ],
        'audio': {
          'id': 'audio_1',
          'data': 'base64data',
          'transcript': 'Hello',
        },
      };
      final resp = OpenAIChatResponse.fromJson(json);
      expect(resp.audio, isNotNull);
      expect(resp.audio!.id, 'audio_1');
      expect(resp.audio!.data, 'base64data');
      expect(resp.audio!.transcript, 'Hello');
    });
  });

  group('OpenAIChoice', () {
    test('fromJson', () {
      final json = {
        'index': 1,
        'message': {'role': 'assistant', 'content': 'test'},
        'finish_reason': 'length',
      };
      final choice = OpenAIChoice.fromJson(json);
      expect(choice.index, 1);
      expect(choice.message.content, 'test');
      expect(choice.finishReason, 'length');
    });
  });

  group('OpenAIUsage', () {
    test('fromJson with all details', () {
      final json = {
        'prompt_tokens': 20,
        'completion_tokens': 30,
        'total_tokens': 50,
        'completion_tokens_details': {'reasoning_tokens': 10},
        'prompt_tokens_details': {
          'cached_tokens': 5,
          'audio_tokens': 2,
          'image_tokens': 8,
          'video_tokens': 0,
        },
      };
      final usage = OpenAIUsage.fromJson(json);
      expect(usage.promptTokens, 20);
      expect(usage.completionTokens, 30);
      expect(usage.totalTokens, 50);
      expect(usage.completionTokensDetails, isNotNull);
      expect(usage.completionTokensDetails!.reasoningTokens, 10);
      expect(usage.promptTokensDetails, isNotNull);
      expect(usage.promptTokensDetails!.cachedTokens, 5);
      expect(usage.promptTokensDetails!.audioTokens, 2);
      expect(usage.promptTokensDetails!.imageTokens, 8);
      expect(usage.promptTokensDetails!.videoTokens, 0);
    });

    test('fromJson without details', () {
      final json = {
        'prompt_tokens': 10,
        'completion_tokens': 5,
        'total_tokens': 15,
      };
      final usage = OpenAIUsage.fromJson(json);
      expect(usage.completionTokensDetails, isNull);
      expect(usage.promptTokensDetails, isNull);
    });
  });

  group('CompletionTokensDetails', () {
    test('fromJson', () {
      final json = {'reasoning_tokens': 42};
      final details = CompletionTokensDetails.fromJson(json);
      expect(details.reasoningTokens, 42);
    });

    test('fromJson with null', () {
      final details = CompletionTokensDetails.fromJson({});
      expect(details.reasoningTokens, isNull);
    });
  });

  group('PromptTokensDetails', () {
    test('fromJson with all fields', () {
      final json = {
        'cached_tokens': 3,
        'audio_tokens': 1,
        'image_tokens': 7,
        'video_tokens': 2,
      };
      final details = PromptTokensDetails.fromJson(json);
      expect(details.cachedTokens, 3);
      expect(details.audioTokens, 1);
      expect(details.imageTokens, 7);
      expect(details.videoTokens, 2);
    });

    test('fromJson with nulls', () {
      final details = PromptTokensDetails.fromJson({});
      expect(details.cachedTokens, isNull);
      expect(details.audioTokens, isNull);
      expect(details.imageTokens, isNull);
      expect(details.videoTokens, isNull);
    });
  });

  group('OpenAIResponseAudio', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 'audio_abc',
        'data': 'base64audio',
        'transcript': 'spoken text',
      };
      final audio = OpenAIResponseAudio.fromJson(json);
      expect(audio.id, 'audio_abc');
      expect(audio.data, 'base64audio');
      expect(audio.transcript, 'spoken text');
    });

    test('fromJson with nulls', () {
      final audio = OpenAIResponseAudio.fromJson({});
      expect(audio.id, isNull);
      expect(audio.data, isNull);
      expect(audio.transcript, isNull);
    });
  });
}
