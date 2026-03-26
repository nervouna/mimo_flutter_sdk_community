import 'anthropic_content.dart';
import 'anthropic_tool.dart';

/// Anthropic messages request.
class AnthropicMessagesRequest {
  const AnthropicMessagesRequest({
    required this.model,
    required this.maxTokens,
    required this.messages,
    this.system,
    this.temperature,
    this.topP,
    this.topK,
    this.tools,
    this.toolChoice,
    this.thinking,
    this.stream = false,
    this.stopSequences,
  });

  final String model;
  final int maxTokens;
  final List<AnthropicMessage> messages;

  /// System prompt — can be a [String] or [List<AnthropicContent>].
  final Object? system;
  final double? temperature;
  final double? topP;
  final int? topK;
  final List<AnthropicTool>? tools;
  final AnthropicToolChoice? toolChoice;
  final AnthropicThinkingConfig? thinking;
  final bool stream;
  final List<String>? stopSequences;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'model': model,
      'max_tokens': maxTokens,
      'messages': messages.map((m) => m.toJson()).toList(),
      'stream': stream,
    };
    if (system is String) {
      json['system'] = system;
    } else if (system is List<AnthropicContent>) {
      json['system'] =
          (system as List<AnthropicContent>).map((c) => c.toJson()).toList();
    }
    if (temperature != null) json['temperature'] = temperature;
    if (topP != null) json['top_p'] = topP;
    if (topK != null) json['top_k'] = topK;
    if (tools != null) {
      json['tools'] = tools!.map((t) => t.toJson()).toList();
    }
    if (toolChoice != null) json['tool_choice'] = toolChoice!.toJson();
    if (thinking != null) json['thinking'] = thinking!.toJson();
    if (stopSequences != null) json['stop_sequences'] = stopSequences;
    return json;
  }
}

/// A message in the Anthropic format.
class AnthropicMessage {
  const AnthropicMessage({
    required this.role,
    required this.content,
  });

  /// Create a user message with text.
  AnthropicMessage.user(String text)
      : role = 'user',
        content = [AnthropicTextContent(text)];

  /// Create a user message with content blocks.
  AnthropicMessage.userBlocks(List<AnthropicContent> blocks)
      : role = 'user',
        content = blocks;

  /// Create an assistant message with text.
  AnthropicMessage.assistant(String text)
      : role = 'assistant',
        content = [AnthropicTextContent(text)];

  /// Create an assistant message with content blocks.
  AnthropicMessage.assistantBlocks(List<AnthropicContent> blocks)
      : role = 'assistant',
        content = blocks;

  final String role;
  final List<AnthropicContent> content;

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content.map((c) => c.toJson()).toList(),
      };

  factory AnthropicMessage.fromJson(Map<String, dynamic> json) {
    final contentValue = json['content'];
    List<AnthropicContent> parsedContent;
    if (contentValue is String) {
      parsedContent = [AnthropicTextContent(contentValue)];
    } else if (contentValue is List) {
      parsedContent = contentValue
          .map((e) =>
              AnthropicContent.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      parsedContent = [];
    }
    return AnthropicMessage(
      role: json['role'] as String,
      content: parsedContent,
    );
  }
}

/// Thinking mode configuration for Anthropic requests.
class AnthropicThinkingConfig {
  const AnthropicThinkingConfig.enabled({this.budgetTokens})
      : type = 'enabled';
  const AnthropicThinkingConfig.disabled()
      : type = 'disabled',
        budgetTokens = null;

  final String type;
  final int? budgetTokens;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': type};
    if (budgetTokens != null) json['budget_tokens'] = budgetTokens;
    return json;
  }
}
