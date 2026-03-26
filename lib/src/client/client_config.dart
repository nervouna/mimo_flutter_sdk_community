import 'package:http/http.dart' as http;

import '../models/common.dart';

/// Configuration for [MimoClient].
class MimoClientConfig {
  const MimoClientConfig({
    required this.apiKey,
    this.baseUrl = 'https://api.xiaomimimo.com',
    this.defaultFormat = MimoApiFormat.openai,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 120),
    this.headers = const {},
    this.httpClient,
  });

  /// MiMo API key.
  final String apiKey;

  /// Base URL for the MiMo API.
  final String baseUrl;

  /// Default API format when none is specified.
  final MimoApiFormat defaultFormat;

  /// Timeout for establishing a connection.
  final Duration connectTimeout;

  /// Timeout for receiving a response.
  final Duration receiveTimeout;

  /// Additional headers to include in every request.
  final Map<String, String> headers;

  /// Optional custom HTTP client (useful for testing or proxy configuration).
  final http.Client? httpClient;

  /// Build the base headers for a given API format.
  Map<String, String> buildHeaders({MimoApiFormat? format}) {
    final f = format ?? defaultFormat;
    return {
      'Content-Type': 'application/json',
      if (f == MimoApiFormat.openai) ...{
        'api-key': apiKey,
        'Authorization': 'Bearer $apiKey',
      } else ...{
        'x-api-key': apiKey,
        'Authorization': 'Bearer $apiKey',
        'anthropic-version': '2023-06-01',
      },
      ...headers,
    };
  }
}
