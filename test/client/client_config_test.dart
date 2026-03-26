import 'package:mimo_flutter_sdk_community/src/client/client_config.dart';
import 'package:mimo_flutter_sdk_community/src/models/common.dart';
import 'package:test/test.dart';

void main() {
  group('MimoClientConfig', () {
    test('default values', () {
      const config = MimoClientConfig(apiKey: 'test-key');
      expect(config.apiKey, 'test-key');
      expect(config.baseUrl, 'https://api.xiaomimimo.com');
      expect(config.defaultFormat, MimoApiFormat.openai);
      expect(config.connectTimeout, const Duration(seconds: 30));
      expect(config.receiveTimeout, const Duration(seconds: 120));
      expect(config.headers, isEmpty);
      expect(config.httpClient, isNull);
    });

    test('custom values', () {
      const config = MimoClientConfig(
        apiKey: 'my-key',
        baseUrl: 'https://custom.api.com',
        defaultFormat: MimoApiFormat.anthropic,
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 60),
        headers: {'X-Custom': 'value'},
      );
      expect(config.apiKey, 'my-key');
      expect(config.baseUrl, 'https://custom.api.com');
      expect(config.defaultFormat, MimoApiFormat.anthropic);
      expect(config.connectTimeout, const Duration(seconds: 10));
      expect(config.receiveTimeout, const Duration(seconds: 60));
      expect(config.headers, {'X-Custom': 'value'});
    });
  });

  group('MimoClientConfig.buildHeaders', () {
    test('openai format headers', () {
      const config = MimoClientConfig(apiKey: 'sk-123');
      final headers = config.buildHeaders(format: MimoApiFormat.openai);
      expect(headers['Content-Type'], 'application/json');
      expect(headers['api-key'], 'sk-123');
      expect(headers['Authorization'], 'Bearer sk-123');
      expect(headers.containsKey('x-api-key'), isFalse);
      expect(headers.containsKey('anthropic-version'), isFalse);
    });

    test('anthropic format headers', () {
      const config = MimoClientConfig(apiKey: 'ant-456');
      final headers = config.buildHeaders(format: MimoApiFormat.anthropic);
      expect(headers['Content-Type'], 'application/json');
      expect(headers['x-api-key'], 'ant-456');
      expect(headers['Authorization'], 'Bearer ant-456');
      expect(headers['anthropic-version'], '2023-06-01');
      expect(headers.containsKey('api-key'), isFalse);
    });

    test('uses defaultFormat when format not specified', () {
      const config = MimoClientConfig(
        apiKey: 'key',
        defaultFormat: MimoApiFormat.anthropic,
      );
      final headers = config.buildHeaders();
      expect(headers['x-api-key'], 'key');
      expect(headers.containsKey('api-key'), isFalse);
    });

    test('custom headers are included', () {
      const config = MimoClientConfig(
        apiKey: 'key',
        headers: {'X-Request-Id': 'abc', 'X-Trace': '123'},
      );
      final headers = config.buildHeaders();
      expect(headers['X-Request-Id'], 'abc');
      expect(headers['X-Trace'], '123');
    });

    test('custom headers can override default headers', () {
      const config = MimoClientConfig(
        apiKey: 'key',
        headers: {'Content-Type': 'text/plain'},
      );
      final headers = config.buildHeaders();
      // Custom headers are spread last, so they override
      expect(headers['Content-Type'], 'text/plain');
    });
  });
}
