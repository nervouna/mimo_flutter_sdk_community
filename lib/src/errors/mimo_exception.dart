/// Base exception for all MiMo API errors.
class MimoException implements Exception {
  const MimoException(this.message, {this.statusCode, this.details});

  final String message;
  final int? statusCode;
  final Object? details;

  @override
  String toString() => 'MimoException($statusCode): $message';
}

/// Network connectivity error.
class MimoNetworkException extends MimoException {
  const MimoNetworkException(super.message, {super.details});

  @override
  String toString() => 'MimoNetworkException: $message';
}

/// Authentication failed (401).
class MimoAuthenticationException extends MimoException {
  const MimoAuthenticationException(super.message)
      : super(statusCode: 401);

  @override
  String toString() => 'MimoAuthenticationException: $message';
}

/// Rate limit exceeded (429).
class MimoRateLimitException extends MimoException {
  const MimoRateLimitException(super.message, {this.retryAfter})
      : super(statusCode: 429);

  final Duration? retryAfter;

  @override
  String toString() => 'MimoRateLimitException: $message';
}

/// Server error (5xx).
class MimoServerException extends MimoException {
  const MimoServerException(super.message, {required int statusCode, super.details})
      : super(statusCode: statusCode);

  @override
  String toString() => 'MimoServerException($statusCode): $message';
}

/// API-level error (400, 403, 421).
class MimoApiException extends MimoException {
  const MimoApiException(super.message, {required int statusCode, super.details})
      : super(statusCode: statusCode);

  @override
  String toString() => 'MimoApiException($statusCode): $message';
}

/// Malformed response JSON.
class MimoInvalidResponseException extends MimoException {
  const MimoInvalidResponseException(super.message, {super.details});

  @override
  String toString() => 'MimoInvalidResponseException: $message';
}
