import '../../utils/json_extractor.dart';
import 'openai_tool.dart';
import 'openai_response.dart';

/// OpenAI streaming chunk response.
class OpenAIChunk {
  const OpenAIChunk({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    this.usage,
  });

  final String id;
  final String object;
  final int created;
  final String model;
  final List<OpenAIChunkChoice> choices;
  final OpenAIUsage? usage;

  factory OpenAIChunk.fromJson(Map<String, dynamic> json) {
    return OpenAIChunk(
      id: JsonExtractor.string(json, 'id'),
      object: JsonExtractor.string(json, 'object'),
      created: JsonExtractor.integer(json, 'created'),
      model: JsonExtractor.string(json, 'model'),
      choices: JsonExtractor.list(json, 'choices')
          .map((e) =>
              OpenAIChunkChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: json['usage'] != null
          ? OpenAIUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// A choice in a streaming chunk.
class OpenAIChunkChoice {
  const OpenAIChunkChoice({
    required this.index,
    required this.delta,
    this.finishReason,
  });

  final int index;
  final OpenAIDelta delta;
  final String? finishReason;

  factory OpenAIChunkChoice.fromJson(Map<String, dynamic> json) {
    return OpenAIChunkChoice(
      index: JsonExtractor.integer(json, 'index'),
      delta: OpenAIDelta.fromJson(
          JsonExtractor.map(json, 'delta')),
      finishReason: json['finish_reason'] as String?,
    );
  }
}

/// Delta in a streaming chunk.
class OpenAIDelta {
  const OpenAIDelta({
    this.role,
    this.content,
    this.reasoningContent,
    this.toolCalls,
    this.audio,
  });

  final String? role;
  final String? content;

  /// Thinking mode: chain-of-thought token.
  final String? reasoningContent;

  final List<OpenAIToolCall>? toolCalls;

  /// TTS audio delta.
  final OpenAIDeltaAudio? audio;

  factory OpenAIDelta.fromJson(Map<String, dynamic> json) {
    List<OpenAIToolCall>? toolCalls;
    if (json['tool_calls'] != null) {
      toolCalls = (json['tool_calls'] as List)
          .map((e) => OpenAIToolCall.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return OpenAIDelta(
      role: json['role'] as String?,
      content: json['content'] as String?,
      reasoningContent: json['reasoning_content'] as String?,
      toolCalls: toolCalls,
      audio: json['audio'] != null
          ? OpenAIDeltaAudio.fromJson(
              json['audio'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Audio delta in streaming TTS responses.
class OpenAIDeltaAudio {
  const OpenAIDeltaAudio({this.id, this.data, this.transcript});

  final String? id;
  final String? data;
  final String? transcript;

  factory OpenAIDeltaAudio.fromJson(Map<String, dynamic> json) {
    return OpenAIDeltaAudio(
      id: json['id'] as String?,
      data: json['data'] as String?,
      transcript: json['transcript'] as String?,
    );
  }
}
