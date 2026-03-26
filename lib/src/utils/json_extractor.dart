import '../errors/mimo_exception.dart';

/// Safe JSON field extraction with descriptive error messages.
class JsonExtractor {
  const JsonExtractor._();

  /// Extracts a required [String] field.
  static String string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw MimoInvalidResponseException(
      'Expected String for "$key", got ${value.runtimeType}',
      details: {'key': key, 'value': value},
    );
  }

  /// Extracts an optional [String] field.
  static String? stringOrNull(Map<String, dynamic> json, String key) {
    return json[key] as String?;
  }

  /// Extracts a required [int] field. Handles [num] → [int] coercion.
  static int integer(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    throw MimoInvalidResponseException(
      'Expected int for "$key", got ${value.runtimeType}',
      details: {'key': key, 'value': value},
    );
  }

  /// Extracts an optional [int] field.
  static int? integerOrNull(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    throw MimoInvalidResponseException(
      'Expected int for "$key", got ${value.runtimeType}',
      details: {'key': key, 'value': value},
    );
  }

  /// Extracts a [List] field. Returns `[]` if null or missing.
  static List<dynamic> list(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is List) return value;
    if (value == null) return <dynamic>[];
    throw MimoInvalidResponseException(
      'Expected List for "$key", got ${value.runtimeType}',
      details: {'key': key, 'value': value},
    );
  }

  /// Extracts a required [Map] field.
  static Map<String, dynamic> map(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    throw MimoInvalidResponseException(
      'Expected Map for "$key", got ${value.runtimeType}',
      details: {'key': key, 'value': value},
    );
  }

  /// Extracts an optional [Map] field.
  static Map<String, dynamic>? mapOrNull(
      Map<String, dynamic> json, String key) {
    return json[key] as Map<String, dynamic>?;
  }

  /// Extracts a [bool] field with optional default.
  static bool boolean(Map<String, dynamic> json, String key,
      {bool defaultValue = false}) {
    final value = json[key];
    if (value is bool) return value;
    if (value == null) return defaultValue;
    throw MimoInvalidResponseException(
      'Expected bool for "$key", got ${value.runtimeType}',
      details: {'key': key, 'value': value},
    );
  }
}
