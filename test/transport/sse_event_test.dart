import 'package:mimo_flutter_sdk_community/src/transport/sse_event.dart';
import 'package:test/test.dart';

void main() {
  group('SseEvent', () {
    test('isDone returns true when data is "[DONE]"', () {
      const event = SseEvent(eventType: '', data: '[DONE]');
      expect(event.isDone, isTrue);
    });

    test('isDone returns false for any other data', () {
      const event = SseEvent(eventType: '', data: '{"id":"1"}');
      expect(event.isDone, isFalse);
    });

    test('isDone returns false for empty data', () {
      const event = SseEvent(eventType: '', data: '');
      expect(event.isDone, isFalse);
    });

    test('toString includes eventType and data', () {
      const event = SseEvent(eventType: 'message_start', data: '{}');
      expect(event.toString(), 'SseEvent(eventType: message_start, data: {})');
    });

    test('eventType defaults to empty string', () {
      const event = SseEvent(eventType: '', data: 'hello');
      expect(event.eventType, '');
    });

    test('stores data correctly', () {
      const event = SseEvent(eventType: 'delta', data: 'multi\nline\ndata');
      expect(event.data, 'multi\nline\ndata');
    });
  });
}
