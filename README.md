# MiMo Flutter SDK Community

[中文文档](README_ZH.md)

Pure Dart client for the [Xiaomi MIMO](https://platform.xiaomimimo.com/) large language model API.

Supports both **OpenAI-compatible** and **Anthropic-compatible** endpoints, streaming, tool use, multimodal inputs, TTS, and thinking mode.

## Features

| Feature | OpenAI endpoint | Anthropic endpoint |
|---------|:-:|:-:|
| Chat completion | ✅ | ✅ |
| Streaming (SSE) | ✅ | ✅ |
| Function calling | ✅ | ✅ |
| Web search | ✅ | — |
| Image understanding | ✅ | ✅ |
| Video understanding | ✅ | — |
| Audio understanding | ✅ | — |
| Text-to-speech (TTS) | ✅ | — |
| Structured output | ✅ | — |
| Thinking mode | ✅ | ✅ |

## Supported models

| Enum | Model ID | Description |
|------|----------|-------------|
| `MimoModel.mimoV2Pro` | `mimo-v2-pro` | Flagship reasoning model |
| `MimoModel.mimoV2Omni` | `mimo-v2-omni` | Multimodal model (image/video/audio) |
| `MimoModel.mimoV2Flash` | `mimo-v2-flash` | Fast, cost-effective model |
| `MimoModel.mimoV2Tts` | `mimo-v2-tts` | Text-to-speech model |

## Installation

```yaml
# pubspec.yaml
dependencies:
  mimo_flutter_sdk_community: ^0.1.0
```

```sh
dart pub get
```

## Quick start

```dart
import 'package:mimo_flutter_sdk_community/mimo_flutter_sdk_community.dart';

final client = MimoClient(
  config: MimoClientConfig(apiKey: 'your-api-key'),
);

// Non-streaming
final response = await client.chat(OpenAIChatRequest(
  model: MimoModel.mimoV2Pro.id,
  messages: [OpenAIMessage.user('Hello, who are you?')],
));
print(response.choices.first.message.content);

// Streaming
await for (final chunk in client.chatStream(OpenAIChatRequest(
  model: MimoModel.mimoV2Pro.id,
  messages: [OpenAIMessage.user('Tell me a story')],
))) {
  final delta = chunk.choices.first.delta;
  if (delta.content != null) {
    stdout.write(delta.content);
  }
}

client.dispose();
```

## Usage

### OpenAI-compatible API

```dart
final response = await client.chat(OpenAIChatRequest(
  model: MimoModel.mimoV2Pro.id,
  messages: [
    OpenAIMessage.system('You are a helpful assistant.'),
    OpenAIMessage.user('What is Flutter?'),
  ],
  temperature: 0.7,
  maxCompletionTokens: 1024,
));
```

### Anthropic-compatible API

```dart
final response = await client.messages(AnthropicMessagesRequest(
  model: MimoModel.mimoV2Pro.id,
  maxTokens: 1024,
  system: 'You are a helpful assistant.',
  messages: [
    AnthropicMessage.user('What is Flutter?'),
  ],
));
```

### Streaming

```dart
// OpenAI streaming
await for (final chunk in client.chatStream(OpenAIChatRequest(
  model: MimoModel.mimoV2Pro.id,
  messages: [OpenAIMessage.user('Write a haiku about Dart')],
))) {
  final delta = chunk.choices.first.delta;
  if (delta.content != null) stdout.write(delta.content);
}

// Anthropic streaming
await for (final event in client.messagesStream(AnthropicMessagesRequest(
  model: MimoModel.mimoV2Pro.id,
  maxTokens: 256,
  messages: [AnthropicMessage.user('Write a haiku about Dart')],
))) {
  if (event is AnthropicContentBlockDeltaEvent) {
    final delta = event.delta;
    if (delta is AnthropicTextDelta) stdout.write(delta.text);
  }
}
```

### Function calling

```dart
final tools = [
  OpenAITool.function(
    name: 'get_weather',
    description: 'Get the current weather in a given city',
    parameters: {
      'type': 'object',
      'properties': {
        'city': {'type': 'string', 'description': 'The city name'},
      },
      'required': ['city'],
    },
  ),
];

final response = await client.chat(OpenAIChatRequest(
  model: MimoModel.mimoV2Pro.id,
  messages: [OpenAIMessage.user('What is the weather in Beijing?')],
  tools: tools,
));

final choice = response.choices.first;
if (choice.message.toolCalls != null) {
  for (final call in choice.message.toolCalls!) {
    print('Call: ${call.function.name}(${call.function.arguments})');
  }
}
```

### Multimodal (image understanding)

```dart
// Image URL
final response = await client.chat(OpenAIChatRequest(
  model: MimoModel.mimoV2Omni.id,
  messages: [
    OpenAIMessage.userContent([
      OpenAIMessageContent.text('Describe this image'),
      OpenAIMessageContent.imageUrl('https://example.com/photo.jpg'),
    ]),
  ],
));

// Base64 image
final base64Data = base64Encode(await File('photo.png').readAsBytes());
final response = await client.chat(OpenAIChatRequest(
  model: MimoModel.mimoV2Omni.id,
  messages: [
    OpenAIMessage.userContent([
      OpenAIMessageContent.text('Describe this image'),
      OpenAIMessageContent.imageBase64(base64Data, 'image/png'),
    ]),
  ],
));
```

### Web search

```dart
final response = await client.chat(OpenAIChatRequest(
  model: MimoModel.mimoV2Pro.id,
  messages: [OpenAIMessage.user('What happened today?')],
  tools: [OpenAITool.webSearch()],
));
```

### Text-to-speech (TTS)

```dart
final audioBytes = await client.tts(
  input: 'Hello, this is MiMo TTS.',
  voice: TtsVoice.mimoDefault,
  format: TtsAudioFormat.wav,
);

await File('output.wav').writeAsBytes(audioBytes);
```

### Thinking mode

```dart
// OpenAI
final response = await client.chat(OpenAIChatRequest(
  model: MimoModel.mimoV2Pro.id,
  messages: [OpenAIMessage.user('Solve: what is 25 * 47?')],
  thinking: OpenAIThinkingConfig.enabled(),
));

final message = response.choices.first.message;
if (message.reasoningContent != null) {
  print('Thinking: ${message.reasoningContent}');
}
print('Answer: ${message.content}');

// Anthropic
final response = await client.messages(AnthropicMessagesRequest(
  model: MimoModel.mimoV2Pro.id,
  maxTokens: 2048,
  messages: [AnthropicMessage.user('Solve: what is 25 * 47?')],
  thinking: AnthropicThinkingConfig.enabled(budgetTokens: 1024),
));
```

### Structured output

```dart
final response = await client.chat(OpenAIChatRequest(
  model: MimoModel.mimoV2Pro.id,
  messages: [
    OpenAIMessage.user(
      'List 3 programming languages. Return JSON: '
      '{"languages": [{"name": "...", "year": 1990}]}',
    ),
  ],
  responseFormat: OpenAIResponseFormat.jsonObject(),
));
```

## Configuration

```dart
final client = MimoClient(
  config: MimoClientConfig(
    apiKey: 'your-api-key',
    baseUrl: 'https://api.xiaomimimo.com',  // default
    defaultFormat: MimoApiFormat.openai,      // default
    connectTimeout: Duration(seconds: 30),    // default
    receiveTimeout: Duration(seconds: 120),   // default
    headers: {'X-Custom': 'value'},           // optional
    httpClient: customHttpClient,             // optional
  ),
);
```

## Error handling

All API errors are thrown as typed exceptions inheriting from `MimoException`:

```dart
try {
  final response = await client.chat(request);
} on MimoAuthenticationException catch (e) {
  // 401 — invalid API key
} on MimoRateLimitException catch (e) {
  // 429 — rate limited, check e.retryAfter
} on MimoApiException catch (e) {
  // 400/403 — bad request
} on MimoServerException catch (e) {
  // 5xx — server error
} on MimoNetworkException catch (e) {
  // network connectivity issue
} on MimoException catch (e) {
  // catch-all
}
```

## Requirements

- Dart SDK >= 3.0.0
- A valid Xiaomi MIMO API key from [platform.xiaomimimo.com](https://platform.xiaomimimo.com/)

## License

MIT
