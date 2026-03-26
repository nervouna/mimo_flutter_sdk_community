/// API format selector.
enum MimoApiFormat {
  openai,
  anthropic,
}

/// Supported model identifiers.
enum MimoModel {
  mimoV2Pro('mimo-v2-pro'),
  mimoV2Omni('mimo-v2-omni'),
  mimoV2Flash('mimo-v2-flash'),
  mimoV2Tts('mimo-v2-tts');

  const MimoModel(this.id);
  final String id;
}

/// Thinking mode configuration.
enum ThinkingMode {
  enabled('enabled'),
  disabled('disabled');

  const ThinkingMode(this.value);
  final String value;
}

/// TTS voice options.
enum TtsVoice {
  mimoDefault('mimo_default'),
  defaultZh('default_zh'),
  defaultEn('default_en');

  const TtsVoice(this.value);
  final String value;
}

/// TTS audio format.
enum TtsAudioFormat {
  wav('wav'),
  pcm16('pcm16');

  const TtsAudioFormat(this.value);
  final String value;
}

/// Finish reason for chat completions.
enum FinishReason {
  stop('stop'),
  length('length'),
  toolCalls('tool_calls'),
  contentFilter('content_filter'),
  endTurn('end_turn'),
  maxTokens('max_tokens');

  const FinishReason(this.value);
  final String value;

  static FinishReason? fromString(String? value) {
    if (value == null) return null;
    for (final reason in FinishReason.values) {
      if (reason.value == value) return reason;
    }
    return null;
  }
}
