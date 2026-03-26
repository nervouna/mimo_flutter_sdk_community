/// Typed wrapper for Anthropic SSE events.
///
/// Carries the SSE event type alongside the decoded JSON payload,
/// allowing the service layer to distinguish between event types
/// like `content_block_start`, `content_block_delta`, etc.
class AnthropicSseData {
  const AnthropicSseData({
    required this.eventType,
    required this.json,
  });

  final String eventType;
  final Map<String, dynamic> json;
}
