import 'dart:async';
import 'dart:convert';

import 'anthropic_sse_data.dart';
import 'sse_event.dart';

/// Parses a byte stream into [SseEvent] objects.
///
/// Handles the SSE protocol:
/// - Ignores lines starting with `:` (comments)
/// - Accumulates `event:` and `data:` lines
/// - Emits on blank line separator
/// - Supports multi-line data (multiple `data:` lines joined by `\n`)
class SseParser {
  /// Parses a byte stream into a stream of raw SSE events.
  static Stream<SseEvent> parse(Stream<List<int>> byteStream) {
    final controller = StreamController<SseEvent>();

    void processLines(Stream<String> lines) {
      String? currentEventType;
      final dataBuffer = StringBuffer();

      lines.listen(
        (line) {
          if (line.isEmpty) {
            // Empty line: emit accumulated event
            if (dataBuffer.isNotEmpty) {
              controller.add(SseEvent(
                eventType: currentEventType ?? '',
                data: dataBuffer.toString(),
              ));
              dataBuffer.clear();
              currentEventType = null;
            }
          } else if (line.startsWith('data:')) {
            final value = line.substring(5);
            if (dataBuffer.isNotEmpty) dataBuffer.write('\n');
            dataBuffer.write(value.startsWith(' ') ? value.substring(1) : value);
          } else if (line.startsWith('event:')) {
            currentEventType = line.substring(6).trimLeft();
          } else if (line.startsWith('id:')) {
            // Not used by MiMo API but part of SSE spec
          } else if (line.startsWith('retry:')) {
            // Not used by MiMo API but part of SSE spec
          }
          // Comment lines (starting with ':') and other lines are ignored
        },
        onDone: controller.close,
        onError: controller.addError,
      );
    }

    processLines(
      byteStream.transform(utf8.decoder).transform(const LineSplitter()),
    );

    return controller.stream;
  }
}

/// Typed SSE parser for OpenAI API format.
///
/// Filters out the `[DONE]` sentinel and decodes JSON data.
class OpenAISseParser {
  /// Returns a stream of parsed JSON maps from the OpenAI SSE stream.
  static Stream<Map<String, dynamic>> parse(Stream<List<int>> byteStream) {
    return SseParser.parse(byteStream)
        .where((event) => !event.isDone)
        .map((event) => jsonDecode(event.data) as Map<String, dynamic>);
  }
}

/// Typed SSE parser for Anthropic API format.
///
/// Returns event type alongside decoded JSON data.
class AnthropicSseParser {
  /// Returns a stream of [AnthropicSseData] from the Anthropic SSE stream.
  static Stream<AnthropicSseData> parse(
    Stream<List<int>> byteStream,
  ) {
    return SseParser.parse(byteStream)
        .where((event) => event.data.isNotEmpty)
        .map((event) {
      final decoded = jsonDecode(event.data) as Map<String, dynamic>;
      return AnthropicSseData(eventType: event.eventType, json: decoded);
    });
  }
}
