import 'package:mimo_flutter_sdk_community/src/models/anthropic/anthropic_tool.dart';
import 'package:test/test.dart';

void main() {
  group('AnthropicTool', () {
    test('toJson with all fields', () {
      const tool = AnthropicTool(
        name: 'get_weather',
        description: 'Get the weather',
        inputSchema: {
          'type': 'object',
          'properties': {
            'location': {'type': 'string'},
          },
        },
      );
      final json = tool.toJson();
      expect(json['name'], 'get_weather');
      expect(json['description'], 'Get the weather');
      expect(json['input_schema']['properties']['location']['type'], 'string');
    });

    test('toJson omits null fields', () {
      const tool = AnthropicTool(name: 'noop');
      final json = tool.toJson();
      expect(json.containsKey('description'), isFalse);
      expect(json.containsKey('input_schema'), isFalse);
    });

    test('fromJson', () {
      final json = {
        'name': 'calc',
        'description': 'Calculator',
        'input_schema': {'type': 'object'},
      };
      final tool = AnthropicTool.fromJson(json);
      expect(tool.name, 'calc');
      expect(tool.description, 'Calculator');
      expect(tool.inputSchema, {'type': 'object'});
    });

    test('fromJson/toJson roundtrip', () {
      const original = AnthropicTool(
        name: 'test',
        description: 'desc',
        inputSchema: {'type': 'object'},
      );
      final restored = AnthropicTool.fromJson(original.toJson());
      expect(restored.name, original.name);
      expect(restored.description, original.description);
      expect(restored.inputSchema, original.inputSchema);
    });
  });

  group('AnthropicToolChoice', () {
    test('auto', () {
      const tc = AnthropicToolChoice.auto();
      expect(tc.toJson(), {'type': 'auto'});
    });

    test('any', () {
      const tc = AnthropicToolChoice.any();
      expect(tc.toJson(), {'type': 'any'});
    });

    test('none', () {
      const tc = AnthropicToolChoice.none();
      expect(tc.toJson(), {'type': 'none'});
    });

    test('tool with name', () {
      final tc = AnthropicToolChoice.tool('my_fn');
      expect(tc.toJson(), {'type': 'tool', 'name': 'my_fn'});
    });
  });
}
