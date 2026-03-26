import 'package:mimo_flutter_sdk_community/src/models/openai/openai_tool.dart';
import 'package:test/test.dart';

void main() {
  group('OpenAIFunctionToolDef', () {
    test('toJson with all fields', () {
      const tool = OpenAIFunctionToolDef(
        name: 'get_weather',
        description: 'Get the weather',
        parameters: {
          'type': 'object',
          'properties': {
            'location': {'type': 'string'},
          },
        },
        strict: true,
      );
      final json = tool.toJson();
      expect(json['type'], 'function');
      expect(json['function']['name'], 'get_weather');
      expect(json['function']['description'], 'Get the weather');
      expect(json['function']['strict'], true);
      expect(json['function']['parameters']['properties']['location']['type'],
          'string');
    });

    test('toJson omits null description and parameters', () {
      const tool = OpenAIFunctionToolDef(name: 'noop');
      final json = tool.toJson();
      expect(json['function'].containsKey('description'), isFalse);
      expect(json['function'].containsKey('parameters'), isFalse);
      expect(json['function']['strict'], false);
    });

    test('factory constructor', () {
      final tool = OpenAITool.function(name: 'test');
      expect(tool, isA<OpenAIFunctionToolDef>());
      expect((tool as OpenAIFunctionToolDef).name, 'test');
    });
  });

  group('OpenAIWebSearchToolDef', () {
    test('toJson with all fields', () {
      const tool = OpenAIWebSearchToolDef(
        maxKeyword: 5,
        forceSearch: true,
        limit: 10,
        userLocation: OpenAIUserLocation(
          country: 'CN',
          region: 'Beijing',
          city: 'Beijing',
          timezone: 'Asia/Shanghai',
        ),
      );
      final json = tool.toJson();
      expect(json['type'], 'web_search');
      expect(json['max_keyword'], 5);
      expect(json['force_search'], true);
      expect(json['limit'], 10);
      expect(json['user_location']['country'], 'CN');
      expect(json['user_location']['type'], 'approximate');
    });

    test('toJson omits null fields', () {
      const tool = OpenAIWebSearchToolDef();
      final json = tool.toJson();
      expect(json, {'type': 'web_search'});
    });

    test('factory constructor', () {
      final tool = OpenAITool.webSearch(forceSearch: true);
      expect(tool, isA<OpenAIWebSearchToolDef>());
    });
  });

  group('OpenAIUserLocation', () {
    test('toJson with all fields', () {
      const loc = OpenAIUserLocation(
        country: 'US',
        region: 'CA',
        city: 'SF',
        timezone: 'America/Los_Angeles',
      );
      final json = loc.toJson();
      expect(json['type'], 'approximate');
      expect(json['country'], 'US');
      expect(json['region'], 'CA');
      expect(json['city'], 'SF');
      expect(json['timezone'], 'America/Los_Angeles');
    });

    test('toJson omits null fields', () {
      const loc = OpenAIUserLocation(country: 'US');
      final json = loc.toJson();
      expect(json['country'], 'US');
      expect(json.containsKey('region'), isFalse);
      expect(json.containsKey('city'), isFalse);
      expect(json.containsKey('timezone'), isFalse);
    });
  });

  group('OpenAIToolCall', () {
    test('fromJson', () {
      final json = {
        'id': 'call_abc123',
        'type': 'function',
        'function': {
          'name': 'get_weather',
          'arguments': '{"location":"Beijing"}',
        },
      };
      final call = OpenAIToolCall.fromJson(json);
      expect(call.id, 'call_abc123');
      expect(call.type, 'function');
      expect(call.function.name, 'get_weather');
      expect(call.function.arguments, '{"location":"Beijing"}');
    });

    test('toJson roundtrip', () {
      const original = OpenAIToolCall(
        id: 'call_1',
        type: 'function',
        function: OpenAIToolCallFunction(
          name: 'test',
          arguments: '{}',
        ),
      );
      final json = original.toJson();
      final restored = OpenAIToolCall.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.function.name, original.function.name);
    });
  });

  group('OpenAIToolCallFunction', () {
    test('parsedArguments parses valid JSON', () {
      const fn = OpenAIToolCallFunction(
        name: 'test',
        arguments: '{"x": 1, "y": "hello"}',
      );
      expect(fn.parsedArguments, {'x': 1, 'y': 'hello'});
    });

    test('parsedArguments returns empty map for JSON null', () {
      const fn = OpenAIToolCallFunction(
        name: 'test',
        arguments: 'null',
      );
      expect(fn.parsedArguments, <String, dynamic>{});
    });

    test('parsedArguments returns empty map for invalid JSON', () {
      const fn = OpenAIToolCallFunction(
        name: 'test',
        arguments: 'not json',
      );
      expect(fn.parsedArguments, <String, dynamic>{});
    });

    test('fromJson/toJson', () {
      final json = {'name': 'fn', 'arguments': '{"a":1}'};
      final fn = OpenAIToolCallFunction.fromJson(json);
      expect(fn.name, 'fn');
      expect(fn.arguments, '{"a":1}');
      expect(fn.toJson(), json);
    });
  });

  group('OpenAIToolChoice', () {
    test('auto serializes to "auto"', () {
      const choice = OpenAIToolChoice.auto();
      expect(choice.toJson(), 'auto');
    });

    test('none serializes to "none"', () {
      const choice = OpenAIToolChoice.none();
      expect(choice.toJson(), 'none');
    });

    test('required_ serializes to "required"', () {
      const choice = OpenAIToolChoice.required_();
      expect(choice.toJson(), 'required');
    });

    test('function serializes to object', () {
      final choice = OpenAIToolChoice.function('my_fn');
      expect(choice.toJson(), {
        'type': 'function',
        'function': {'name': 'my_fn'},
      });
    });
  });

  group('OpenAIResponseFormat', () {
    test('text', () {
      const rf = OpenAIResponseFormat.text();
      expect(rf.toJson(), {'type': 'text'});
    });

    test('jsonObject', () {
      const rf = OpenAIResponseFormat.jsonObject();
      expect(rf.toJson(), {'type': 'json_object'});
    });
  });

  group('OpenAIThinkingConfig', () {
    test('enabled', () {
      const tc = OpenAIThinkingConfig.enabled();
      expect(tc.toJson(), {'type': 'enabled'});
    });

    test('disabled', () {
      const tc = OpenAIThinkingConfig.disabled();
      expect(tc.toJson(), {'type': 'disabled'});
    });
  });
}
