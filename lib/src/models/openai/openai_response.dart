import '../../utils/json_extractor.dart';
import 'openai_request.dart';

/// OpenAI chat completion response.
class OpenAIChatResponse {
  const OpenAIChatResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    this.usage,
    this.audio,
  });

  final String id;
  final String object;
  final int created;
  final String model;
  final List<OpenAIChoice> choices;
  final OpenAIUsage? usage;
  final OpenAIResponseAudio? audio;

  factory OpenAIChatResponse.fromJson(Map<String, dynamic> json) {
    return OpenAIChatResponse(
      id: JsonExtractor.string(json, 'id'),
      object: JsonExtractor.string(json, 'object'),
      created: JsonExtractor.integer(json, 'created'),
      model: JsonExtractor.string(json, 'model'),
      choices: JsonExtractor.list(json, 'choices')
          .map((e) => OpenAIChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: json['usage'] != null
          ? OpenAIUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
      audio: json['audio'] != null
          ? OpenAIResponseAudio.fromJson(
              json['audio'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// A choice in the completion response.
class OpenAIChoice {
  const OpenAIChoice({
    required this.index,
    required this.message,
    this.finishReason,
  });

  final int index;
  final OpenAIMessage message;
  final String? finishReason;

  factory OpenAIChoice.fromJson(Map<String, dynamic> json) {
    return OpenAIChoice(
      index: JsonExtractor.integer(json, 'index'),
      message: OpenAIMessage.fromJson(
        JsonExtractor.map(json, 'message'),
      ),
      finishReason: json['finish_reason'] as String?,
    );
  }
}

/// Token usage information.
class OpenAIUsage {
  const OpenAIUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    this.completionTokensDetails,
    this.promptTokensDetails,
  });

  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final CompletionTokensDetails? completionTokensDetails;
  final PromptTokensDetails? promptTokensDetails;

  factory OpenAIUsage.fromJson(Map<String, dynamic> json) {
    return OpenAIUsage(
      promptTokens: JsonExtractor.integer(json, 'prompt_tokens'),
      completionTokens: JsonExtractor.integer(json, 'completion_tokens'),
      totalTokens: JsonExtractor.integer(json, 'total_tokens'),
      completionTokensDetails: json['completion_tokens_details'] != null
          ? CompletionTokensDetails.fromJson(
              json['completion_tokens_details'] as Map<String, dynamic>)
          : null,
      promptTokensDetails: json['prompt_tokens_details'] != null
          ? PromptTokensDetails.fromJson(
              json['prompt_tokens_details'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Details about completion token usage.
class CompletionTokensDetails {
  const CompletionTokensDetails({this.reasoningTokens});

  final int? reasoningTokens;

  factory CompletionTokensDetails.fromJson(Map<String, dynamic> json) {
    return CompletionTokensDetails(
      reasoningTokens: json['reasoning_tokens'] as int?,
    );
  }
}

/// Details about prompt token usage.
class PromptTokensDetails {
  const PromptTokensDetails({
    this.cachedTokens,
    this.audioTokens,
    this.imageTokens,
    this.videoTokens,
  });

  final int? cachedTokens;
  final int? audioTokens;
  final int? imageTokens;
  final int? videoTokens;

  factory PromptTokensDetails.fromJson(Map<String, dynamic> json) {
    return PromptTokensDetails(
      cachedTokens: json['cached_tokens'] as int?,
      audioTokens: json['audio_tokens'] as int?,
      imageTokens: json['image_tokens'] as int?,
      videoTokens: json['video_tokens'] as int?,
    );
  }
}

/// Audio data from TTS responses.
class OpenAIResponseAudio {
  const OpenAIResponseAudio({this.id, this.data, this.transcript});

  final String? id;
  final String? data;
  final String? transcript;

  factory OpenAIResponseAudio.fromJson(Map<String, dynamic> json) {
    return OpenAIResponseAudio(
      id: json['id'] as String?,
      data: json['data'] as String?,
      transcript: json['transcript'] as String?,
    );
  }
}
