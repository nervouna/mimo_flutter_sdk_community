/// A raw Server-Sent Event.
///
/// For OpenAI API: [eventType] is always empty (no `event:` lines).
/// For Anthropic API: [eventType] is one of message_start, content_block_start, etc.
class SseEvent {
  const SseEvent({required this.eventType, required this.data});

  /// The event type from the `event:` line, or empty string if absent.
  final String eventType;

  /// The data from `data:` line(s), joined by newlines.
  final String data;

  /// Whether this is the OpenAI stream termination sentinel.
  bool get isDone => data == '[DONE]';

  @override
  String toString() => 'SseEvent(eventType: $eventType, data: $data)';
}
