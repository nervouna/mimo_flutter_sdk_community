import 'package:http/http.dart' as http;
import 'package:mimo_flutter_sdk_community/src/errors/error_mapper.dart';
import 'package:mimo_flutter_sdk_community/src/errors/mimo_exception.dart';
import 'package:test/test.dart';

void main() {
  group('ErrorMapper.fromResponse', () {
    test('401 returns MimoAuthenticationException', () {
      final response = http.Response(
        '{"error":{"message":"Invalid API key"}}',
        401,
      );
      final ex = ErrorMapper.fromResponse(response);
      expect(ex, isA<MimoAuthenticationException>());
      expect(ex.statusCode, 401);
      expect(ex.message, 'Invalid API key');
    });

    test('429 returns MimoRateLimitException', () {
      final response = http.Response(
        '{"message":"Rate limit exceeded"}',
        429,
      );
      final ex = ErrorMapper.fromResponse(response);
      expect(ex, isA<MimoRateLimitException>());
      expect(ex.statusCode, 429);
      expect(ex.message, 'Rate limit exceeded');
    });

    test('429 with retry-after header', () {
      final response = http.Response(
        '{"message":"Too many requests"}',
        429,
        headers: {'retry-after': '30'},
      );
      final ex = ErrorMapper.fromResponse(response);
      expect(ex, isA<MimoRateLimitException>());
      final rateLimit = ex as MimoRateLimitException;
      expect(rateLimit.retryAfter, Duration(seconds: 30));
    });

    test('429 without retry-after header', () {
      final response = http.Response('{"message":"Too many"}', 429);
      final ex = ErrorMapper.fromResponse(response) as MimoRateLimitException;
      expect(ex.retryAfter, isNull);
    });

    test('429 with non-integer retry-after returns null duration', () {
      final response = http.Response(
        'rate limited',
        429,
        headers: {'retry-after': 'Wed, 11 Mar 2026 00:00:00 GMT'},
      );
      final ex = ErrorMapper.fromResponse(response) as MimoRateLimitException;
      expect(ex.retryAfter, isNull);
    });

    test('500 returns MimoServerException', () {
      final response = http.Response(
        '{"error":{"message":"Internal error"}}',
        500,
      );
      final ex = ErrorMapper.fromResponse(response);
      expect(ex, isA<MimoServerException>());
      expect(ex.statusCode, 500);
      expect(ex.message, 'Internal error');
    });

    test('502 returns MimoServerException', () {
      final response = http.Response('Bad Gateway', 502);
      final ex = ErrorMapper.fromResponse(response);
      expect(ex, isA<MimoServerException>());
      expect(ex.statusCode, 502);
    });

    test('503 returns MimoServerException', () {
      final response = http.Response('Service Unavailable', 503);
      final ex = ErrorMapper.fromResponse(response);
      expect(ex, isA<MimoServerException>());
      expect(ex.statusCode, 503);
    });

    test('400 returns MimoApiException', () {
      final response = http.Response(
        '{"error":{"message":"Bad request"}}',
        400,
      );
      final ex = ErrorMapper.fromResponse(response);
      expect(ex, isA<MimoApiException>());
      expect(ex.statusCode, 400);
      expect(ex.message, 'Bad request');
    });

    test('403 returns MimoApiException', () {
      final response = http.Response('Forbidden', 403);
      final ex = ErrorMapper.fromResponse(response);
      expect(ex, isA<MimoApiException>());
      expect(ex.statusCode, 403);
    });

    test('404 returns MimoApiException', () {
      final response = http.Response('Not Found', 404);
      final ex = ErrorMapper.fromResponse(response);
      expect(ex, isA<MimoApiException>());
      expect(ex.statusCode, 404);
    });
  });

  group('ErrorMapper.fromResponse message extraction', () {
    test('extracts from {"error":{"message":"..."}} format', () {
      final response = http.Response(
        '{"error":{"message":"Invalid API key","type":"auth_error"}}',
        401,
      );
      expect(ErrorMapper.fromResponse(response).message, 'Invalid API key');
    });

    test('extracts from {"message":"..."} format', () {
      final response = http.Response(
        '{"message":"Rate limited","code":429}',
        429,
      );
      expect(ErrorMapper.fromResponse(response).message, 'Rate limited');
    });

    test('extracts from plain text (<=500 chars)', () {
      final response = http.Response('Internal Server Error', 500);
      expect(ErrorMapper.fromResponse(response).message, 'Internal Server Error');
    });

    test('falls back to "Unknown error" for long plain text (>500 chars)', () {
      final longBody = 'x' * 501;
      final response = http.Response(longBody, 500);
      expect(ErrorMapper.fromResponse(response).message, 'Unknown error');
    });

    test('empty body returns empty string as message', () {
      final response = http.Response('', 500);
      // Empty string is <= 500 chars, so _extractMessage returns ''
      expect(ErrorMapper.fromResponse(response).message, '');
    });

    test('falls back to "Unknown error" for JSON without message fields', () {
      final response = http.Response('{"code": 400}', 400);
      expect(ErrorMapper.fromResponse(response).message, 'Unknown error');
    });

    test('error.message takes precedence over top-level message', () {
      final response = http.Response(
        '{"error":{"message":"inner"},"message":"outer"}',
        400,
      );
      expect(ErrorMapper.fromResponse(response).message, 'inner');
    });
  });

  group('ErrorMapper.fromClientException', () {
    test('returns MimoNetworkException', () {
      final clientEx = http.ClientException('Connection refused');
      final ex = ErrorMapper.fromClientException(clientEx);
      expect(ex, isA<MimoNetworkException>());
      expect(ex.message, 'Connection refused');
      expect(ex.details, same(clientEx));
    });
  });
}
