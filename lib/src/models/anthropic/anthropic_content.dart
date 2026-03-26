import 'dart:convert';

import '../../utils/json_extractor.dart';

/// Anthropic content block types.
///
/// Messages contain a list of content blocks that can be text, thinking,
/// tool use, tool results, or images.
sealed class AnthropicContent {
  const AnthropicContent();

  Map<String, dynamic> toJson();

  factory AnthropicContent.text(String text) = AnthropicTextContent;
  factory AnthropicContent.thinking({
    required String thinking,
    required String signature,
  }) = AnthropicThinkingContent;
  factory AnthropicContent.redactedThinking(String data) =
      AnthropicRedactedThinkingContent;
  factory AnthropicContent.toolUse({
    required String id,
    required String name,
    required Map<String, dynamic> input,
  }) = AnthropicToolUseContent;
  factory AnthropicContent.toolResult({
    required String toolUseId,
    required dynamic content,
    bool isError,
  }) = AnthropicToolResultContent;
  factory AnthropicContent.image({
    required String type,
    required String mediaType,
    required String data,
  }) = AnthropicImageContent;

  factory AnthropicContent.fromJson(Map<String, dynamic> json) {
    final type = JsonExtractor.string(json, 'type');
    switch (type) {
      case 'text':
        return AnthropicTextContent(JsonExtractor.string(json, 'text'));
      case 'thinking':
        return AnthropicThinkingContent(
          thinking: json['thinking'] as String? ?? '',
          signature: json['signature'] as String? ?? '',
        );
      case 'redacted_thinking':
        return AnthropicRedactedThinkingContent(
            JsonExtractor.string(json, 'data'));
      case 'tool_use':
        return AnthropicToolUseContent(
          id: JsonExtractor.string(json, 'id'),
          name: JsonExtractor.string(json, 'name'),
          input: JsonExtractor.map(json, 'input'),
        );
      case 'tool_result':
        final contentValue = json['content'];
        dynamic parsedContent;
        if (contentValue is String) {
          parsedContent = contentValue;
        } else if (contentValue is List) {
          parsedContent = contentValue
              .map((e) =>
                  AnthropicContent.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          parsedContent = contentValue;
        }
        return AnthropicToolResultContent(
          toolUseId: JsonExtractor.string(json, 'tool_use_id'),
          content: parsedContent,
          isError: json['is_error'] as bool? ?? false,
        );
      case 'image':
        final source = JsonExtractor.map(json, 'source');
        return AnthropicImageContent(
          type: JsonExtractor.string(source, 'type'),
          mediaType: JsonExtractor.string(source, 'media_type'),
          data: JsonExtractor.string(source, 'data'),
        );
      default:
        return AnthropicTextContent(jsonEncode(json));
    }
  }
}

/// Plain text content block.
class AnthropicTextContent extends AnthropicContent {
  const AnthropicTextContent(this.text);

  final String text;

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};
}

/// Thinking content block (extended thinking output).
class AnthropicThinkingContent extends AnthropicContent {
  const AnthropicThinkingContent({
    required this.thinking,
    required this.signature,
  });

  final String thinking;
  final String signature;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'thinking',
        'thinking': thinking,
        'signature': signature,
      };
}

/// Redacted thinking content block.
class AnthropicRedactedThinkingContent extends AnthropicContent {
  const AnthropicRedactedThinkingContent(this.data);

  final String data;

  @override
  Map<String, dynamic> toJson() => {'type': 'redacted_thinking', 'data': data};
}

/// Tool use content block (model requesting a tool call).
class AnthropicToolUseContent extends AnthropicContent {
  const AnthropicToolUseContent({
    required this.id,
    required this.name,
    required this.input,
  });

  final String id;
  final String name;
  final Map<String, dynamic> input;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'tool_use',
        'id': id,
        'name': name,
        'input': input,
      };
}

/// Tool result content block (returning tool output to the model).
class AnthropicToolResultContent extends AnthropicContent {
  const AnthropicToolResultContent({
    required this.toolUseId,
    required this.content,
    this.isError = false,
  });

  final String toolUseId;

  /// String, List<AnthropicContent>, or null.
  final dynamic content;
  final bool isError;

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': 'tool_result',
      'tool_use_id': toolUseId,
      'is_error': isError,
    };
    if (content is String) {
      json['content'] = content;
    } else if (content is List<AnthropicContent>) {
      json['content'] =
          (content as List<AnthropicContent>).map((c) => c.toJson()).toList();
    } else if (content != null) {
      json['content'] = content;
    }
    return json;
  }
}

/// Image content block (base64).
class AnthropicImageContent extends AnthropicContent {
  const AnthropicImageContent({
    required this.type,
    required this.mediaType,
    required this.data,
  });

  /// Should be "base64".
  final String type;
  final String mediaType;
  final String data;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'image',
        'source': {
          'type': type,
          'media_type': mediaType,
          'data': data,
        },
      };
}
