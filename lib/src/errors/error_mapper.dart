import 'dart:convert';

import 'package:http/http.dart' as http;

import 'mimo_exception.dart';

/// Maps HTTP errors to typed [MimoException] instances.
class ErrorMapper {
  /// Maps an HTTP response to a [MimoException].
  ///
  /// [body] is the raw response body string.
  static MimoException fromResponse(http.Response response) {
    final statusCode = response.statusCode;
    final message = _extractMessage(response.body) ?? 'Unknown error';

    switch (statusCode) {
      case 401:
        return MimoAuthenticationException(message);
      case 429:
        return MimoRateLimitException(
          message,
          retryAfter: _parseRetryAfter(response.headers),
        );
      case >= 500:
        return MimoServerException(message, statusCode: statusCode);
      default:
        return MimoApiException(message, statusCode: statusCode);
    }
  }

  /// Maps an HTTP client exception to [MimoNetworkException].
  static MimoNetworkException fromClientException(
    http.ClientException e,
  ) {
    return MimoNetworkException(e.message, details: e);
  }

  static String? _extractMessage(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        // {"error": {"message": "..."}}
        final error = json['error'];
        if (error is Map<String, dynamic>) {
          return error['message'] as String?;
        }
        // {"message": "..."}
        return json['message'] as String?;
      }
    } catch (_) {
      // Not JSON, return body itself if short enough
      if (body.length <= 500) return body;
    }
    return null;
  }

  static Duration? _parseRetryAfter(Map<String, String> headers) {
    final value = headers['retry-after'];
    if (value == null) return null;
    final seconds = int.tryParse(value);
    if (seconds != null) return Duration(seconds: seconds);
    return null;
  }
}
