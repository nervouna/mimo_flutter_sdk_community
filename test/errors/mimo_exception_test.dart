import 'package:mimo_flutter_sdk_community/mimo_flutter_sdk_community.dart';
import 'package:test/test.dart';

void main() {
  group('MimoException', () {
    test('stores message, statusCode, details', () {
      const e = MimoException('not found', statusCode: 404, details: {'key': 'val'});
      expect(e.message, 'not found');
      expect(e.statusCode, 404);
      expect(e.details, {'key': 'val'});
    });

    test('toString format', () {
      const e = MimoException('not found', statusCode: 404);
      expect(e.toString(), 'MimoException(404): not found');
    });

    test('statusCode and details default to null', () {
      const e = MimoException('error');
      expect(e.statusCode, isNull);
      expect(e.details, isNull);
    });
  });

  group('MimoNetworkException', () {
    test('stores message and details', () {
      final original = Exception('original');
      final e = MimoNetworkException('connection refused', details: original);
      expect(e.message, 'connection refused');
      expect(e.details, original);
    });

    test('statusCode is null', () {
      const e = MimoNetworkException('error');
      expect(e.statusCode, isNull);
    });

    test('toString format', () {
      const e = MimoNetworkException('connection refused');
      expect(e.toString(), 'MimoNetworkException: connection refused');
    });
  });

  group('MimoAuthenticationException', () {
    test('statusCode is always 401', () {
      const e = MimoAuthenticationException('bad key');
      expect(e.statusCode, 401);
    });

    test('toString format', () {
      const e = MimoAuthenticationException('bad key');
      expect(e.toString(), 'MimoAuthenticationException: bad key');
    });
  });

  group('MimoRateLimitException', () {
    test('statusCode is always 429', () {
      const e = MimoRateLimitException('slow down');
      expect(e.statusCode, 429);
    });

    test('stores optional retryAfter Duration', () {
      const e = MimoRateLimitException('slow down', retryAfter: Duration(seconds: 30));
      expect(e.retryAfter, const Duration(seconds: 30));
    });

    test('retryAfter is null when not provided', () {
      const e = MimoRateLimitException('slow down');
      expect(e.retryAfter, isNull);
    });

    test('toString format', () {
      const e = MimoRateLimitException('slow down');
      expect(e.toString(), 'MimoRateLimitException: slow down');
    });
  });

  group('MimoServerException', () {
    test('stores statusCode', () {
      const e = MimoServerException('internal', statusCode: 500);
      expect(e.statusCode, 500);
      expect(e.message, 'internal');
    });

    test('toString format', () {
      const e = MimoServerException('internal', statusCode: 500);
      expect(e.toString(), 'MimoServerException(500): internal');
    });
  });

  group('MimoApiException', () {
    test('stores statusCode', () {
      const e = MimoApiException('bad request', statusCode: 400);
      expect(e.statusCode, 400);
      expect(e.message, 'bad request');
    });

    test('toString format', () {
      const e = MimoApiException('forbidden', statusCode: 403);
      expect(e.toString(), 'MimoApiException(403): forbidden');
    });
  });

  group('MimoInvalidResponseException', () {
    test('stores message and optional details', () {
      const e = MimoInvalidResponseException('bad json', details: 'raw body');
      expect(e.message, 'bad json');
      expect(e.details, 'raw body');
    });

    test('statusCode is null', () {
      const e = MimoInvalidResponseException('bad json');
      expect(e.statusCode, isNull);
    });

    test('toString format', () {
      const e = MimoInvalidResponseException('bad json');
      expect(e.toString(), 'MimoInvalidResponseException: bad json');
    });
  });
}
