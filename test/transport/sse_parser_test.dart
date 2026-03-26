import 'dart:convert';

import 'package:mimo_flutter_sdk_community/src/transport/sse_event.dart';
import 'package:mimo_flutter_sdk_community/src/transport/sse_parser.dart';
import 'package:test/test.dart';

/// Helper to create a byte stream from a string.
Stream<List<int>> _byteStream(String text) =>
    Stream.value(utf8.encode(text));

/// Helper to create a byte stream from multiple chunks.
Stream<List<int>> _multiChunkStream(List<String> chunks) =>
    Stream.fromIterable(chunks.map(utf8.encode));

void main() {
  group('SseParser.parse', () {
    test('single data event', () async {
      final events = await SseParser.parse(_byteStream('data: hello\n\n')).toList();
      expect(events, hasLength(1));
      expect(events[0].data, 'hello');
      expect(events[0].eventType, '');
    });

    test('data with leading space is trimmed', () async {
      final events = await SseParser.parse(_byteStream('data: hello\n\n')).toList();
      expect(events[0].data, 'hello');
    });

    test('data without leading space', () async {
      final events = await SseParser.parse(_byteStream('data:hello\n\n')).toList();
      expect(events[0].data, 'hello');
    });

    test('multiple data lines joined by newline', () async {
      final input = 'data: line1\ndata: line2\n\n';
      final events = await SseParser.parse(_byteStream(input)).toList();
      expect(events, hasLength(1));
      expect(events[0].data, 'line1\nline2');
    });

    test('event type from event: line', () async {
      final input = 'event: message_start\ndata: {"type":"start"}\n\n';
      final events = await SseParser.parse(_byteStream(input)).toList();
      expect(events, hasLength(1));
      expect(events[0].eventType, 'message_start');
      expect(events[0].data, '{"type":"start"}');
    });

    test('multiple events', () async {
      final input = 'data: first\n\nevent: test\ndata: second\n\n';
      final events = await SseParser.parse(_byteStream(input)).toList();
      expect(events, hasLength(2));
      expect(events[0].data, 'first');
      expect(events[0].eventType, '');
      expect(events[1].data, 'second');
      expect(events[1].eventType, 'test');
    });

    test('comment lines are ignored', () async {
      final input = ': this is a comment\ndata: real data\n\n';
      final events = await SseParser.parse(_byteStream(input)).toList();
      expect(events, hasLength(1));
      expect(events[0].data, 'real data');
    });

    test('id: and retry: lines are ignored (no data emitted)', () async {
      final input = 'id: 42\nretry: 5000\n\n';
      final events = await SseParser.parse(_byteStream(input)).toList();
      expect(events, isEmpty);
    });

    test('empty lines without data are ignored', () async {
      final input = '\n\ndata: hello\n\n\n';
      final events = await SseParser.parse(_byteStream(input)).toList();
      expect(events, hasLength(1));
      expect(events[0].data, 'hello');
    });

    test('empty stream produces no events', () async {
      final events = await SseParser.parse(Stream<List<int>>.empty()).toList();
      expect(events, isEmpty);
    });

    test('event type persists until changed', () async {
      final input = 'event: delta\ndata: a\n\ndata: b\n\n';
      final events = await SseParser.parse(_byteStream(input)).toList();
      expect(events, hasLength(2));
      expect(events[0].eventType, 'delta');
      expect(events[1].eventType, '');
    });

    test('multi-chunk stream', () async {
      final events = await SseParser.parse(
        _multiChunkStream(['data: hel', 'lo\n\n']),
      ).toList();
      expect(events, hasLength(1));
      expect(events[0].data, 'hello');
    });
  });

  group('OpenAISseParser.parse', () {
    test('parses JSON events', () async {
      final input = 'data: {"id":"1","choices":[]}\n\n';
      final events = await OpenAISseParser.parse(_byteStream(input)).toList();
      expect(events, hasLength(1));
      expect(events[0], isA<Map<String, dynamic>>());
      expect(events[0]['id'], '1');
    });

    test('filters out [DONE] sentinel', () async {
      final input = 'data: {"id":"1"}\n\ndata: [DONE]\n\n';
      final events = await OpenAISseParser.parse(_byteStream(input)).toList();
      expect(events, hasLength(1));
      expect(events[0]['id'], '1');
    });

    test('only [DONE] produces empty stream', () async {
      final events = await OpenAISseParser.parse(_byteStream('data: [DONE]\n\n')).toList();
      expect(events, isEmpty);
    });

    test('multiple JSON events', () async {
      final input = 'data: {"a":1}\n\ndata: {"b":2}\n\n';
      final events = await OpenAISseParser.parse(_byteStream(input)).toList();
      expect(events, hasLength(2));
      expect(events[0]['a'], 1);
      expect(events[1]['b'], 2);
    });
  });

  group('AnthropicSseParser.parse', () {
    test('returns AnthropicSseData with eventType and json', () async {
      final input = 'event: message_start\ndata: {"type":"message_start","message":{"id":"msg_1"}}\n\n';
      final events = await AnthropicSseParser.parse(_byteStream(input)).toList();
      expect(events, hasLength(1));
      expect(events[0].eventType, 'message_start');
      expect(events[0].json['type'], 'message_start');
    });

    test('filters out events with empty data', () async {
      final input = 'event: ping\n\nevent: message_start\ndata: {"type":"start"}\n\n';
      final events = await AnthropicSseParser.parse(_byteStream(input)).toList();
      expect(events, hasLength(1));
      expect(events[0].eventType, 'message_start');
    });

    test('multiple events', () async {
      final input =
          'event: message_start\ndata: {"type":"message_start"}\n\n'
          'event: content_block_delta\ndata: {"type":"content_block_delta"}\n\n';
      final events = await AnthropicSseParser.parse(_byteStream(input)).toList();
      expect(events, hasLength(2));
      expect(events[0].eventType, 'message_start');
      expect(events[1].eventType, 'content_block_delta');
    });

    test('event without event: line has empty eventType', () async {
      final input = 'data: {"type":"unknown"}\n\n';
      final events = await AnthropicSseParser.parse(_byteStream(input)).toList();
      expect(events, hasLength(1));
      expect(events[0].eventType, '');
      expect(events[0].json['type'], 'unknown');
    });
  });

  group('SseEvent', () {
    test('isDone for [DONE]', () {
      const event = SseEvent(eventType: '', data: '[DONE]');
      expect(event.isDone, isTrue);
    });

    test('isDone is false for other data', () {
      const event = SseEvent(eventType: '', data: '{"id":"1"}');
      expect(event.isDone, isFalse);
    });

    test('toString', () {
      const event = SseEvent(eventType: 'test', data: 'hello');
      expect(event.toString(), 'SseEvent(eventType: test, data: hello)');
    });
  });
}
