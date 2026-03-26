import 'dart:convert';

import 'package:mimo_flutter_sdk_community/src/models/openai/openai_content.dart';
import 'package:test/test.dart';

void main() {
  group('OpenAITextContent', () {
    test('toJson', () {
      const c = OpenAITextContent('hello');
      expect(c.toJson(), {'type': 'text', 'text': 'hello'});
    });

    test('fromJson roundtrip', () {
      const original = OpenAITextContent('world');
      final json = original.toJson();
      final restored = OpenAIMessageContent.fromJson(json);
      expect(restored, isA<OpenAITextContent>());
      expect((restored as OpenAITextContent).text, 'world');
    });
  });

  group('OpenAIImageContent', () {
    test('toJson', () {
      const c = OpenAIImageContent('https://example.com/img.png');
      expect(c.toJson(), {
        'type': 'image_url',
        'image_url': {'url': 'https://example.com/img.png'},
      });
    });

    test('fromJson roundtrip', () {
      const original = OpenAIImageContent('https://example.com/pic.jpg');
      final json = original.toJson();
      final restored = OpenAIMessageContent.fromJson(json);
      expect(restored, isA<OpenAIImageContent>());
      expect((restored as OpenAIImageContent).url, 'https://example.com/pic.jpg');
    });
  });

  group('OpenAIImageBase64Content', () {
    test('toJson encodes data URI', () {
      const c = OpenAIImageBase64Content('abc123', 'image/png');
      final json = c.toJson();
      expect(json['type'], 'image_url');
      expect(json['image_url']['url'], 'data:image/png;base64,abc123');
    });

    test('fromJson roundtrip with data URI', () {
      const original = OpenAIImageBase64Content('Zm9v', 'image/jpeg');
      final json = original.toJson();
      final restored = OpenAIMessageContent.fromJson(json);
      expect(restored, isA<OpenAIImageBase64Content>());
      final base64 = restored as OpenAIImageBase64Content;
      expect(base64.base64Data, 'Zm9v');
      expect(base64.mimeType, 'image/jpeg');
    });
  });

  group('OpenAIVideoContent', () {
    test('toJson with defaults', () {
      const c = OpenAIVideoContent('https://example.com/vid.mp4');
      final json = c.toJson();
      expect(json['type'], 'video_url');
      expect(json['video_url'], {'url': 'https://example.com/vid.mp4'});
      expect(json['fps'], 2.0);
      expect(json['media_resolution'], 'default');
    });

    test('toJson with custom fps and resolution', () {
      const c = OpenAIVideoContent(
        'https://example.com/vid.mp4',
        fps: 1.0,
        mediaResolution: 'low',
      );
      final json = c.toJson();
      expect(json['fps'], 1.0);
      expect(json['media_resolution'], 'low');
    });

    test('fromJson roundtrip', () {
      const original = OpenAIVideoContent(
        'https://example.com/vid.mp4',
        fps: 3.0,
        mediaResolution: 'high',
      );
      final json = original.toJson();
      final restored = OpenAIMessageContent.fromJson(json);
      expect(restored, isA<OpenAIVideoContent>());
      final video = restored as OpenAIVideoContent;
      expect(video.url, 'https://example.com/vid.mp4');
      expect(video.fps, 3.0);
      expect(video.mediaResolution, 'high');
    });
  });

  group('OpenAIInputAudioContent', () {
    test('toJson with defaults', () {
      const c = OpenAIInputAudioContent('base64audiodata');
      final json = c.toJson();
      expect(json['type'], 'input_audio');
      expect(json['input_audio'], {'data': 'base64audiodata', 'format': 'wav'});
    });

    test('toJson with custom format', () {
      const c = OpenAIInputAudioContent('data123', format: 'mp3');
      final json = c.toJson();
      expect(json['input_audio']['format'], 'mp3');
    });

    test('fromJson roundtrip', () {
      const original = OpenAIInputAudioContent('abc', format: 'pcm16');
      final json = original.toJson();
      final restored = OpenAIMessageContent.fromJson(json);
      expect(restored, isA<OpenAIInputAudioContent>());
      final audio = restored as OpenAIInputAudioContent;
      expect(audio.data, 'abc');
      expect(audio.format, 'pcm16');
    });
  });

  group('OpenAIMessageContent.fromJson', () {
    test('unknown type falls back to text with jsonEncode', () {
      final json = {'type': 'unknown', 'foo': 'bar'};
      final content = OpenAIMessageContent.fromJson(json);
      expect(content, isA<OpenAITextContent>());
      expect((content as OpenAITextContent).text, jsonEncode(json));
    });
  });

  group('OpenAIMessageContent factory constructors', () {
    test('.text creates OpenAITextContent', () {
      final c = OpenAIMessageContent.text('hi');
      expect(c, isA<OpenAITextContent>());
    });

    test('.imageUrl creates OpenAIImageContent', () {
      final c = OpenAIMessageContent.imageUrl('https://img.png');
      expect(c, isA<OpenAIImageContent>());
    });

    test('.imageBase64 creates OpenAIImageBase64Content', () {
      final c = OpenAIMessageContent.imageBase64('data', 'image/png');
      expect(c, isA<OpenAIImageBase64Content>());
    });

    test('.videoUrl creates OpenAIVideoContent', () {
      final c = OpenAIMessageContent.videoUrl('https://vid.mp4');
      expect(c, isA<OpenAIVideoContent>());
    });

    test('.inputAudio creates OpenAIInputAudioContent', () {
      final c = OpenAIMessageContent.inputAudio('data');
      expect(c, isA<OpenAIInputAudioContent>());
    });
  });

  group('OpenAIContentConverter', () {
    const converter = OpenAIContentConverter();

    test('fromJson returns String as-is', () {
      expect(converter.fromJson('hello'), 'hello');
    });

    test('fromJson converts List to content parts', () {
      final json = [
        {'type': 'text', 'text': 'hi'},
        {
          'type': 'image_url',
          'image_url': {'url': 'https://img.png'},
        },
      ];
      final result = converter.fromJson(json);
      expect(result, isA<List<OpenAIMessageContent>>());
      final list = result as List<OpenAIMessageContent>;
      expect(list, hasLength(2));
      expect(list[0], isA<OpenAITextContent>());
      expect(list[1], isA<OpenAIImageContent>());
    });

    test('fromJson returns other types as-is', () {
      expect(converter.fromJson(42), 42);
      expect(converter.fromJson(null), isNull);
    });

    test('toJson returns String as-is', () {
      expect(converter.toJson('hello'), 'hello');
    });

    test('toJson converts List<OpenAIMessageContent>', () {
      final parts = [
        const OpenAITextContent('hi'),
        const OpenAIImageContent('https://img.png'),
      ];
      final result = converter.toJson(parts);
      expect(result, isA<List>());
      final list = result as List;
      expect(list[0], {'type': 'text', 'text': 'hi'});
      expect(list[1]['type'], 'image_url');
    });

    test('toJson returns other types as-is', () {
      expect(converter.toJson(42), 42);
    });
  });
}
