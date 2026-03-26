import 'openai_content.dart';
import 'openai_tool.dart';

/// OpenAI chat completion request.
class OpenAIChatRequest {
  const OpenAIChatRequest({
    required this.model,
    required this.messages,
    this.temperature,
    this.topP,
    this.maxCompletionTokens,
    this.tools,
    this.toolChoice,
    this.responseFormat,
    this.thinking,
    this.stream = false,
    this.audio,
    this.frequencyPenalty,
    this.presencePenalty,
    this.stop,
  });

  final String model;
  final List<OpenAIMessage> messages;
  final double? temperature;
  final double? topP;
  final int? maxCompletionTokens;
  final List<OpenAITool>? tools;
  final OpenAIToolChoice? toolChoice;
  final OpenAIResponseFormat? responseFormat;
  final OpenAIThinkingConfig? thinking;
  final bool stream;
  final OpenAIAudioConfig? audio;
  final double? frequencyPenalty;
  final double? presencePenalty;
  final List<String>? stop;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'model': model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'stream': stream,
    };
    if (temperature != null) json['temperature'] = temperature;
    if (topP != null) json['top_p'] = topP;
    if (maxCompletionTokens != null) {
      json['max_completion_tokens'] = maxCompletionTokens;
    }
    if (tools != null) {
      json['tools'] = tools!.map((t) => t.toJson()).toList();
    }
    if (toolChoice != null) json['tool_choice'] = toolChoice!.toJson();
    if (responseFormat != null) {
      json['response_format'] = responseFormat!.toJson();
    }
    if (thinking != null) json['thinking'] = thinking!.toJson();
    if (audio != null) json['audio'] = audio!.toJson();
    if (frequencyPenalty != null) {
      json['frequency_penalty'] = frequencyPenalty;
    }
    if (presencePenalty != null) json['presence_penalty'] = presencePenalty;
    if (stop != null) json['stop'] = stop;
    return json;
  }
}

/// A message in the OpenAI chat format.
class OpenAIMessage {
  const OpenAIMessage({
    required this.role,
    this.content,
    this.name,
    this.toolCalls,
    this.toolCallId,
    this.reasoningContent,
  });

  /// Create a system message.
  OpenAIMessage.system(String text)
      : role = 'system',
        content = text,
        name = null,
        toolCalls = null,
        toolCallId = null,
        reasoningContent = null;

  /// Create a developer message.
  OpenAIMessage.developer(String text)
      : role = 'developer',
        content = text,
        name = null,
        toolCalls = null,
        toolCallId = null,
        reasoningContent = null;

  /// Create a user message with text.
  OpenAIMessage.user(String text)
      : role = 'user',
        content = text,
        name = null,
        toolCalls = null,
        toolCallId = null,
        reasoningContent = null;

  /// Create a user message with multimodal content.
  OpenAIMessage.userContent(List<OpenAIMessageContent> parts)
      : role = 'user',
        content = parts,
        name = null,
        toolCalls = null,
        toolCallId = null,
        reasoningContent = null;

  /// Create an assistant message.
  OpenAIMessage.assistant(String text, {String? reasoningContent})
      : role = 'assistant',
        content = text,
        name = null,
        toolCalls = null,
        toolCallId = null,
        reasoningContent = reasoningContent;

  /// Create a tool result message.
  OpenAIMessage.tool({
    required String toolCallId,
    required String content,
  })  : role = 'tool',
        content = content,
        name = null,
        toolCalls = null,
        toolCallId = toolCallId,
        reasoningContent = null;

  final String role;

  /// String or List<OpenAIMessageContent>.
  final dynamic content;
  final String? name;
  final List<OpenAIToolCall>? toolCalls;
  final String? toolCallId;

  /// Chain-of-thought content (for thinking mode, preserved across turns).
  final String? reasoningContent;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'role': role};
    if (content is String) {
      json['content'] = content;
    } else if (content is List<OpenAIMessageContent>) {
      json['content'] =
          (content as List<OpenAIMessageContent>).map((c) => c.toJson()).toList();
    }
    if (name != null) json['name'] = name;
    if (toolCalls != null) {
      json['tool_calls'] = toolCalls!.map((t) => t.toJson()).toList();
    }
    if (toolCallId != null) json['tool_call_id'] = toolCallId;
    if (reasoningContent != null) {
      json['reasoning_content'] = reasoningContent;
    }
    return json;
  }

  factory OpenAIMessage.fromJson(Map<String, dynamic> json) {
    final contentValue = json['content'];
    dynamic parsedContent;
    if (contentValue is String) {
      parsedContent = contentValue;
    } else if (contentValue is List) {
      parsedContent = contentValue
          .map((e) =>
              OpenAIMessageContent.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<OpenAIToolCall>? toolCalls;
    if (json['tool_calls'] != null) {
      toolCalls = (json['tool_calls'] as List)
          .map((e) => OpenAIToolCall.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return OpenAIMessage(
      role: json['role'] as String,
      content: parsedContent,
      toolCalls: toolCalls,
      toolCallId: json['tool_call_id'] as String?,
      reasoningContent: json['reasoning_content'] as String?,
    );
  }
}

/// Audio configuration for TTS requests.
class OpenAIAudioConfig {
  const OpenAIAudioConfig({
    this.format = 'wav',
    this.voice = 'mimo_default',
  });

  final String format;
  final String voice;

  Map<String, dynamic> toJson() => {
        'format': format,
        'voice': voice,
      };
}
