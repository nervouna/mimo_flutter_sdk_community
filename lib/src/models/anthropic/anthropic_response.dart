import '../../utils/json_extractor.dart';
import 'anthropic_content.dart';

/// Anthropic messages response.
class AnthropicMessagesResponse {
  const AnthropicMessagesResponse({
    required this.id,
    required this.type,
    required this.role,
    required this.content,
    required this.model,
    required this.stopReason,
    this.stopSequence,
    this.usage,
  });

  final String id;
  final String type;
  final String role;
  final List<AnthropicContent> content;
  final String model;
  final String? stopReason;
  final String? stopSequence;
  final AnthropicUsage? usage;

  factory AnthropicMessagesResponse.fromJson(Map<String, dynamic> json) {
    return AnthropicMessagesResponse(
      id: JsonExtractor.string(json, 'id'),
      type: JsonExtractor.string(json, 'type'),
      role: JsonExtractor.string(json, 'role'),
      content: JsonExtractor.list(json, 'content')
          .map((e) =>
              AnthropicContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      model: JsonExtractor.string(json, 'model'),
      stopReason: json['stop_reason'] as String?,
      stopSequence: json['stop_sequence'] as String?,
      usage: json['usage'] != null
          ? AnthropicUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Token usage information for Anthropic.
class AnthropicUsage {
  const AnthropicUsage({
    this.inputTokens,
    this.outputTokens,
    this.cacheCreationInputTokens,
    this.cacheReadInputTokens,
  });

  final int? inputTokens;
  final int? outputTokens;
  final int? cacheCreationInputTokens;
  final int? cacheReadInputTokens;

  factory AnthropicUsage.fromJson(Map<String, dynamic> json) {
    return AnthropicUsage(
      inputTokens: json['input_tokens'] as int?,
      outputTokens: json['output_tokens'] as int?,
      cacheCreationInputTokens:
          json['cache_creation_input_tokens'] as int?,
      cacheReadInputTokens: json['cache_read_input_tokens'] as int?,
    );
  }
}
