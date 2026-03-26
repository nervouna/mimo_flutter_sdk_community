import '../../utils/json_extractor.dart';
import 'anthropic_content.dart';
import 'anthropic_response.dart';

/// Anthropic streaming event types.
///
/// The Anthropic API sends named SSE events during streaming.
/// This sealed class represents all possible event types.
sealed class AnthropicStreamEvent {
  const AnthropicStreamEvent();

  String get type;

  factory AnthropicStreamEvent.fromJson(Map<String, dynamic> json) {
    final eventType = JsonExtractor.string(json, 'type');
    switch (eventType) {
      case 'message_start':
        return AnthropicMessageStartEvent.fromJson(json);
      case 'message_delta':
        return AnthropicMessageDeltaEvent.fromJson(json);
      case 'message_stop':
        return AnthropicMessageStopEvent.fromJson(json);
      case 'content_block_start':
        return AnthropicContentBlockStartEvent.fromJson(json);
      case 'content_block_delta':
        return AnthropicContentBlockDeltaEvent.fromJson(json);
      case 'content_block_stop':
        return AnthropicContentBlockStopEvent.fromJson(json);
      case 'ping':
        return const AnthropicPingEvent();
      case 'error':
        return AnthropicErrorEvent.fromJson(json);
      case 'input_json_delta':
        return AnthropicInputJsonDeltaEvent.fromJson(json);
      default:
        return AnthropicUnknownEvent(eventType: eventType, data: json);
    }
  }
}

/// message_start event — contains the initial message with id, role, model.
class AnthropicMessageStartEvent extends AnthropicStreamEvent {
  const AnthropicMessageStartEvent({required this.message});

  @override
  String get type => 'message_start';

  final AnthropicMessagesResponse message;

  factory AnthropicMessageStartEvent.fromJson(Map<String, dynamic> json) {
    return AnthropicMessageStartEvent(
      message: AnthropicMessagesResponse.fromJson(
        JsonExtractor.map(json, 'message'),
      ),
    );
  }
}

/// message_delta event — contains the final delta with stop_reason and usage.
class AnthropicMessageDeltaEvent extends AnthropicStreamEvent {
  const AnthropicMessageDeltaEvent({required this.delta, this.usage});

  @override
  String get type => 'message_delta';

  final AnthropicMessageDelta delta;
  final AnthropicUsage? usage;

  factory AnthropicMessageDeltaEvent.fromJson(Map<String, dynamic> json) {
    return AnthropicMessageDeltaEvent(
      delta: AnthropicMessageDelta.fromJson(
        JsonExtractor.map(json, 'delta'),
      ),
      usage: json['usage'] != null
          ? AnthropicUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Delta within a message_delta event.
class AnthropicMessageDelta {
  const AnthropicMessageDelta({this.stopReason, this.stopSequence});

  final String? stopReason;
  final String? stopSequence;

  factory AnthropicMessageDelta.fromJson(Map<String, dynamic> json) {
    return AnthropicMessageDelta(
      stopReason: json['stop_reason'] as String?,
      stopSequence: json['stop_sequence'] as String?,
    );
  }
}

/// message_stop event — signals the end of the message.
class AnthropicMessageStopEvent extends AnthropicStreamEvent {
  const AnthropicMessageStopEvent();

  @override
  String get type => 'message_stop';

  factory AnthropicMessageStopEvent.fromJson(Map<String, dynamic> json) {
    return const AnthropicMessageStopEvent();
  }
}

/// content_block_start event — signals the start of a content block.
class AnthropicContentBlockStartEvent extends AnthropicStreamEvent {
  const AnthropicContentBlockStartEvent({
    required this.index,
    required this.contentBlock,
  });

  @override
  String get type => 'content_block_start';

  final int index;
  final AnthropicContent contentBlock;

  factory AnthropicContentBlockStartEvent.fromJson(
      Map<String, dynamic> json) {
    return AnthropicContentBlockStartEvent(
      index: JsonExtractor.integer(json, 'index'),
      contentBlock: AnthropicContent.fromJson(
        JsonExtractor.map(json, 'content_block'),
      ),
    );
  }
}

/// content_block_delta event — incremental content for a block.
class AnthropicContentBlockDeltaEvent extends AnthropicStreamEvent {
  const AnthropicContentBlockDeltaEvent({
    required this.index,
    required this.delta,
  });

  @override
  String get type => 'content_block_delta';

  final int index;
  final AnthropicContentDelta delta;

  factory AnthropicContentBlockDeltaEvent.fromJson(
      Map<String, dynamic> json) {
    return AnthropicContentBlockDeltaEvent(
      index: JsonExtractor.integer(json, 'index'),
      delta: AnthropicContentDelta.fromJson(
        JsonExtractor.map(json, 'delta'),
      ),
    );
  }
}

/// The delta within a content_block_delta event.
sealed class AnthropicContentDelta {
  const AnthropicContentDelta();

  String get type;

  factory AnthropicContentDelta.fromJson(Map<String, dynamic> json) {
    final type = JsonExtractor.string(json, 'type');
    switch (type) {
      case 'text_delta':
        return AnthropicTextDelta(JsonExtractor.string(json, 'text'));
      case 'thinking_delta':
        return AnthropicThinkingDelta(JsonExtractor.string(json, 'thinking'));
      case 'signature_delta':
        return AnthropicSignatureDelta(
            JsonExtractor.string(json, 'signature'));
      case 'input_json_delta':
        return AnthropicInputJsonDelta(
            JsonExtractor.string(json, 'partial_json'));
      default:
        return AnthropicUnknownDelta(type: type, data: json);
    }
  }
}

/// Text delta.
class AnthropicTextDelta extends AnthropicContentDelta {
  const AnthropicTextDelta(this.text);

  @override
  String get type => 'text_delta';

  final String text;
}

/// Thinking delta (extended thinking output token).
class AnthropicThinkingDelta extends AnthropicContentDelta {
  const AnthropicThinkingDelta(this.thinking);

  @override
  String get type => 'thinking_delta';

  final String thinking;
}

/// Signature delta (extended thinking signature).
class AnthropicSignatureDelta extends AnthropicContentDelta {
  const AnthropicSignatureDelta(this.signature);

  @override
  String get type => 'signature_delta';

  final String signature;
}

/// Input JSON delta (tool use input streaming).
class AnthropicInputJsonDelta extends AnthropicContentDelta {
  const AnthropicInputJsonDelta(this.partialJson);

  @override
  String get type => 'input_json_delta';

  final String partialJson;
}

/// Unknown delta type for forward compatibility.
class AnthropicUnknownDelta extends AnthropicContentDelta {
  const AnthropicUnknownDelta({required this.type, required this.data});

  @override
  final String type;
  final Map<String, dynamic> data;
}

/// content_block_stop event — signals the end of a content block.
class AnthropicContentBlockStopEvent extends AnthropicStreamEvent {
  const AnthropicContentBlockStopEvent({required this.index});

  @override
  String get type => 'content_block_stop';

  final int index;

  factory AnthropicContentBlockStopEvent.fromJson(
      Map<String, dynamic> json) {
    return AnthropicContentBlockStopEvent(
      index: JsonExtractor.integer(json, 'index'),
    );
  }
}

/// ping event.
class AnthropicPingEvent extends AnthropicStreamEvent {
  const AnthropicPingEvent();

  @override
  String get type => 'ping';
}

/// error event.
class AnthropicErrorEvent extends AnthropicStreamEvent {
  const AnthropicErrorEvent({required this.error});

  @override
  String get type => 'error';

  final AnthropicError error;

  factory AnthropicErrorEvent.fromJson(Map<String, dynamic> json) {
    return AnthropicErrorEvent(
      error: AnthropicError.fromJson(
          JsonExtractor.map(json, 'error')),
    );
  }
}

/// Error details in an error event.
class AnthropicError {
  const AnthropicError({required this.type, required this.message});

  final String type;
  final String message;

  factory AnthropicError.fromJson(Map<String, dynamic> json) {
    return AnthropicError(
      type: JsonExtractor.string(json, 'type'),
      message: JsonExtractor.string(json, 'message'),
    );
  }
}

/// input_json_delta event (top-level, for tool use streaming).
class AnthropicInputJsonDeltaEvent extends AnthropicStreamEvent {
  const AnthropicInputJsonDeltaEvent({required this.partialJson});

  @override
  String get type => 'input_json_delta';

  final String partialJson;

  factory AnthropicInputJsonDeltaEvent.fromJson(Map<String, dynamic> json) {
    return AnthropicInputJsonDeltaEvent(
      partialJson: JsonExtractor.string(json, 'partial_json'),
    );
  }
}

/// Unknown event type for forward compatibility.
class AnthropicUnknownEvent extends AnthropicStreamEvent {
  const AnthropicUnknownEvent({required this.eventType, required this.data});

  @override
  String get type => eventType;

  final String eventType;
  final Map<String, dynamic> data;
}
