import 'dart:convert';

import '../../utils/json_extractor.dart';

/// OpenAI message content parts.
///
/// Messages can contain text, images, videos, or audio.
/// The [content] field in a message can be a plain string or a list of content parts.
sealed class OpenAIMessageContent {
  const OpenAIMessageContent();

  Map<String, dynamic> toJson();

  factory OpenAIMessageContent.text(String text) = OpenAITextContent;
  factory OpenAIMessageContent.imageUrl(String url) = OpenAIImageContent;
  factory OpenAIMessageContent.imageBase64(
    String base64Data,
    String mimeType,
  ) = OpenAIImageBase64Content;
  factory OpenAIMessageContent.videoUrl(
    String url, {
    double fps,
    String mediaResolution,
  }) = OpenAIVideoContent;
  factory OpenAIMessageContent.inputAudio(
    String data, {
    String format,
  }) = OpenAIInputAudioContent;

  /// Deserialize from JSON.
  factory OpenAIMessageContent.fromJson(Map<String, dynamic> json) {
    final type = JsonExtractor.string(json, 'type');
    switch (type) {
      case 'text':
        return OpenAITextContent(JsonExtractor.string(json, 'text'));
      case 'image_url':
        final imageUrl = JsonExtractor.map(json, 'image_url');
        final url = JsonExtractor.string(imageUrl, 'url');
        if (url.startsWith('data:')) {
          final parts = url.split(',');
          final mimePart = parts.first;
          final mime = mimePart.substring(mimePart.indexOf(':') + 1,
              mimePart.indexOf(';'));
          return OpenAIImageBase64Content(parts.last, mime);
        }
        return OpenAIImageContent(url);
      case 'video_url':
        final videoUrl = JsonExtractor.map(json, 'video_url');
        return OpenAIVideoContent(
          JsonExtractor.string(videoUrl, 'url'),
          fps: (json['fps'] as num?)?.toDouble() ?? 2.0,
          mediaResolution:
              json['media_resolution'] as String? ?? 'default',
        );
      case 'input_audio':
        final inputAudio = JsonExtractor.map(json, 'input_audio');
        return OpenAIInputAudioContent(
          JsonExtractor.string(inputAudio, 'data'),
          format: inputAudio['format'] as String? ?? 'wav',
        );
      default:
        return OpenAITextContent(jsonEncode(json));
    }
  }
}

/// Plain text content.
class OpenAITextContent extends OpenAIMessageContent {
  const OpenAITextContent(this.text);

  final String text;

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};
}

/// Image URL content.
class OpenAIImageContent extends OpenAIMessageContent {
  const OpenAIImageContent(this.url);

  final String url;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'image_url',
        'image_url': {'url': url},
      };
}

/// Image base64 content.
class OpenAIImageBase64Content extends OpenAIMessageContent {
  const OpenAIImageBase64Content(this.base64Data, this.mimeType);

  final String base64Data;
  final String mimeType;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'image_url',
        'image_url': {'url': 'data:$mimeType;base64,$base64Data'},
      };
}

/// Video URL content.
class OpenAIVideoContent extends OpenAIMessageContent {
  const OpenAIVideoContent(
    this.url, {
    this.fps = 2.0,
    this.mediaResolution = 'default',
  });

  final String url;
  final double fps;
  final String mediaResolution;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'video_url',
        'video_url': {'url': url},
        'fps': fps,
        'media_resolution': mediaResolution,
      };
}

/// Audio input content.
class OpenAIInputAudioContent extends OpenAIMessageContent {
  const OpenAIInputAudioContent(this.data, {this.format = 'wav'});

  /// URL or data URI (data:audio/wav;base64,...)
  final String data;
  final String format;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'input_audio',
        'input_audio': {'data': data, 'format': format},
      };
}

/// Converter for polymorphic content field (String | List<OpenAIMessageContent>).
class OpenAIContentConverter {
  const OpenAIContentConverter();

  dynamic fromJson(dynamic json) {
    if (json is String) return json;
    if (json is List) {
      return json
          .map((e) =>
              OpenAIMessageContent.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return json;
  }

  dynamic toJson(dynamic object) {
    if (object is String) return object;
    if (object is List<OpenAIMessageContent>) {
      return object.map((e) => e.toJson()).toList();
    }
    return object;
  }
}
