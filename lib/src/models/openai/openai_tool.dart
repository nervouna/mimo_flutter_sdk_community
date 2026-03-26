import 'dart:convert';

import '../../utils/json_extractor.dart';

/// OpenAI tool definitions.
///
/// Tools can be function tools or the web_search tool.
sealed class OpenAITool {
  const OpenAITool();

  Map<String, dynamic> toJson();

  factory OpenAITool.function({
    required String name,
    String? description,
    Map<String, dynamic>? parameters,
    bool strict,
  }) = OpenAIFunctionToolDef;

  factory OpenAITool.webSearch({
    int? maxKeyword,
    bool? forceSearch,
    int? limit,
    OpenAIUserLocation? userLocation,
  }) = OpenAIWebSearchToolDef;
}

/// Function tool definition.
///
/// ```json
/// {"type": "function", "function": {"name": "...", "description": "...", "parameters": {...}}}
/// ```
class OpenAIFunctionToolDef extends OpenAITool {
  const OpenAIFunctionToolDef({
    required this.name,
    this.description,
    this.parameters,
    this.strict = false,
  });

  final String name;
  final String? description;
  final Map<String, dynamic>? parameters;
  final bool strict;

  @override
  Map<String, dynamic> toJson() {
    final function = <String, dynamic>{'name': name};
    if (description != null) function['description'] = description;
    if (parameters != null) function['parameters'] = parameters;
    function['strict'] = strict;
    return {'type': 'function', 'function': function};
  }
}

/// Web search tool definition.
///
/// ```json
/// {"type": "web_search", "max_keyword": 3, "force_search": true, "limit": 1}
/// ```
class OpenAIWebSearchToolDef extends OpenAITool {
  const OpenAIWebSearchToolDef({
    this.maxKeyword,
    this.forceSearch,
    this.limit,
    this.userLocation,
  });

  final int? maxKeyword;
  final bool? forceSearch;
  final int? limit;
  final OpenAIUserLocation? userLocation;

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': 'web_search'};
    if (maxKeyword != null) json['max_keyword'] = maxKeyword;
    if (forceSearch != null) json['force_search'] = forceSearch;
    if (limit != null) json['limit'] = limit;
    if (userLocation != null) json['user_location'] = userLocation!.toJson();
    return json;
  }
}

/// User location for web search.
class OpenAIUserLocation {
  const OpenAIUserLocation({
    this.country,
    this.region,
    this.city,
    this.timezone,
  });

  final String? country;
  final String? region;
  final String? city;
  final String? timezone;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': 'approximate'};
    if (country != null) json['country'] = country;
    if (region != null) json['region'] = region;
    if (city != null) json['city'] = city;
    if (timezone != null) json['timezone'] = timezone;
    return json;
  }
}

/// Tool call from the model's response.
class OpenAIToolCall {
  const OpenAIToolCall({
    required this.id,
    required this.type,
    required this.function,
  });

  final String id;
  final String type;
  final OpenAIToolCallFunction function;

  factory OpenAIToolCall.fromJson(Map<String, dynamic> json) {
    return OpenAIToolCall(
      id: JsonExtractor.string(json, 'id'),
      type: JsonExtractor.string(json, 'type'),
      function: OpenAIToolCallFunction.fromJson(
        JsonExtractor.map(json, 'function'),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'function': function.toJson(),
      };
}

/// Function call details from the model.
class OpenAIToolCallFunction {
  const OpenAIToolCallFunction({
    required this.name,
    required this.arguments,
  });

  final String name;

  /// JSON string of arguments.
  final String arguments;

  factory OpenAIToolCallFunction.fromJson(Map<String, dynamic> json) {
    return OpenAIToolCallFunction(
      name: JsonExtractor.string(json, 'name'),
      arguments: JsonExtractor.string(json, 'arguments'),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'arguments': arguments,
      };

  /// Parsed arguments as a Map.
  Map<String, dynamic> get parsedArguments =>
      _jsonDecode(arguments) as Map<String, dynamic>;

  static dynamic _jsonDecode(String s) {
    try {
      return _parseJson(s);
    } catch (_) {
      return {};
    }
  }

  static dynamic _parseJson(String s) => jsonDecode(s);
}

/// Tool choice configuration.
class OpenAIToolChoice {
  const OpenAIToolChoice.auto() : _value = 'auto';
  const OpenAIToolChoice.none() : _value = 'none';
  const OpenAIToolChoice.required_() : _value = 'required';
  factory OpenAIToolChoice.function(String name) =>
      OpenAIToolChoice._({'type': 'function', 'function': {'name': name}});

  const OpenAIToolChoice._(this._value);

  final dynamic _value;

  dynamic toJson() => _value;
}

/// Response format configuration.
class OpenAIResponseFormat {
  const OpenAIResponseFormat.text() : type = 'text';
  const OpenAIResponseFormat.jsonObject() : type = 'json_object';

  final String type;

  Map<String, dynamic> toJson() => {'type': type};
}

/// Thinking mode configuration for requests.
class OpenAIThinkingConfig {
  const OpenAIThinkingConfig.enabled() : type = 'enabled';
  const OpenAIThinkingConfig.disabled() : type = 'disabled';

  final String type;

  Map<String, dynamic> toJson() => {'type': type};
}
