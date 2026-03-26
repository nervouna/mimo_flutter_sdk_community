import '../../utils/json_extractor.dart';

/// Tool definition for the Anthropic API.
class AnthropicTool {
  const AnthropicTool({
    required this.name,
    this.description,
    this.inputSchema,
  });

  final String name;
  final String? description;
  final Map<String, dynamic>? inputSchema;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'name': name};
    if (description != null) json['description'] = description;
    if (inputSchema != null) json['input_schema'] = inputSchema;
    return json;
  }

  factory AnthropicTool.fromJson(Map<String, dynamic> json) {
    return AnthropicTool(
      name: JsonExtractor.string(json, 'name'),
      description: json['description'] as String?,
      inputSchema: json['input_schema'] as Map<String, dynamic>?,
    );
  }
}

/// Tool choice configuration for the Anthropic API.
class AnthropicToolChoice {
  const AnthropicToolChoice.auto() : type = 'auto', name = null;
  const AnthropicToolChoice.any() : type = 'any', name = null;
  const AnthropicToolChoice.none() : type = 'none', name = null;
  const AnthropicToolChoice.tool(String toolName)
      : type = 'tool',
        name = toolName;

  final String type;
  final String? name;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': type};
    if (name != null) json['name'] = name;
    return json;
  }
}
