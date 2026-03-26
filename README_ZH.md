# MiMo Flutter SDK Community

[English](README.md)

基于纯 Dart 的 [小米 MIMO](https://platform.xiaomimimo.com/) 大语言模型 API 客户端。

兼容 **OpenAI** 和 **Anthropic** 两种接口格式，支持流式输出、工具调用、多模态输入、TTS、思考模式等能力。

## 功能特性

| 功能 | OpenAI 接口 | Anthropic 接口 |
|------|:-:|:-:|
| 对话补全 | ✅ | ✅ |
| 流式输出 (SSE) | ✅ | ✅ |
| 工具调用 | ✅ | ✅ |
| 联网搜索 | ✅ | — |
| 图片理解 | ✅ | ✅ |
| 视频理解 | ✅ | — |
| 音频理解 | ✅ | — |
| 语音合成 (TTS) | ✅ | — |
| 结构化输出 | ✅ | — |
| 思考模式 | ✅ | ✅ |

## 支持的模型

| 枚举值 | 模型 ID | 说明 |
|--------|---------|------|
| `MimoModel.mimoV2Pro` | `mimo-v2-pro` | 旗舰推理模型 |
| `MimoModel.mimoV2Omni` | `mimo-v2-omni` | 多模态模型（图片/视频/音频） |
| `MimoModel.mimoV2Flash` | `mimo-v2-flash` | 轻量快速模型 |
| `MimoModel.mimoV2Tts` | `mimo-v2-tts` | 语音合成模型 |

## 安装

```yaml
# pubspec.yaml
dependencies:
  mimo_flutter_sdk_community: ^0.1.0
```

```sh
dart pub get
```

## 快速上手

```dart
import 'package:mimo_flutter_sdk_community/mimo_flutter_sdk_community.dart';

final client = MimoClient(
  config: MimoClientConfig(apiKey: 'your-api-key'),
);

// 同步调用
final response = await client.chat(OpenAIChatRequest(
  model: MimoModel.mimoV2Pro.id,
  messages: [OpenAIMessage.user('你好，你是谁？')],
));
print(response.choices.first.message.content);

// 流式调用
await for (final chunk in client.chatStream(OpenAIChatRequest(
  model: MimoModel.mimoV2Pro.id,
  messages: [OpenAIMessage.user('讲个故事')],
))) {
  final delta = chunk.choices.first.delta;
  if (delta.content != null) {
    stdout.write(delta.content);
  }
}

client.dispose();
```

## 使用方法

### OpenAI 接口

```dart
final response = await client.chat(OpenAIChatRequest(
  model: MimoModel.mimoV2Pro.id,
  messages: [
    OpenAIMessage.system('你是一个 Flutter 工程师。'),
    OpenAIMessage.user('什么是 Flutter？'),
  ],
  temperature: 0.7,
  maxCompletionTokens: 1024,
));
```

### Anthropic 接口

```dart
final response = await client.messages(AnthropicMessagesRequest(
  model: MimoModel.mimoV2Pro.id,
  maxTokens: 1024,
  system: '你是一个 Flutter 工程师。',
  messages: [
    AnthropicMessage.user('什么是 Flutter？'),
  ],
));
```

### 流式输出

```dart
// OpenAI
await for (final chunk in client.chatStream(OpenAIChatRequest(
  model: MimoModel.mimoV2Pro.id,
  messages: [OpenAIMessage.user('写一首关于 Dart 的诗')],
))) {
  final delta = chunk.choices.first.delta;
  if (delta.content != null) stdout.write(delta.content);
}

// Anthropic
await for (final event in client.messagesStream(AnthropicMessagesRequest(
  model: MimoModel.mimoV2Pro.id,
  maxTokens: 256,
  messages: [AnthropicMessage.user('写一首关于 Dart 的诗')],
))) {
  if (event is AnthropicContentBlockDeltaEvent) {
    final delta = event.delta;
    if (delta is AnthropicTextDelta) stdout.write(delta.text);
  }
}
```

### 工具调用

```dart
final tools = [
  OpenAITool.function(
    name: 'get_weather',
    description: '获取指定城市的当前天气',
    parameters: {
      'type': 'object',
      'properties': {
        'city': {'type': 'string', 'description': '城市名称'},
      },
      'required': ['city'],
    },
  ),
];

final response = await client.chat(OpenAIChatRequest(
  model: MimoModel.mimoV2Pro.id,
  messages: [OpenAIMessage.user('北京今天天气怎么样？')],
  tools: tools,
));

final choice = response.choices.first;
if (choice.message.toolCalls != null) {
  for (final call in choice.message.toolCalls!) {
    print('调用: ${call.function.name}(${call.function.arguments})');
  }
}
```

### 图片理解

```dart
// 图片 URL
final response = await client.chat(OpenAIChatRequest(
  model: MimoModel.mimoV2Omni.id,
  messages: [
    OpenAIMessage.userContent([
      OpenAIMessageContent.text('描述这张图片'),
      OpenAIMessageContent.imageUrl('https://example.com/photo.jpg'),
    ]),
  ],
));

// Base64 图片
final base64Data = base64Encode(await File('photo.png').readAsBytes());
final response = await client.chat(OpenAIChatRequest(
  model: MimoModel.mimoV2Omni.id,
  messages: [
    OpenAIMessage.userContent([
      OpenAIMessageContent.text('描述这张图片'),
      OpenAIMessageContent.imageBase64(base64Data, 'image/png'),
    ]),
  ],
));
```

### 联网搜索

```dart
final response = await client.chat(OpenAIChatRequest(
  model: MimoModel.mimoV2Pro.id,
  messages: [OpenAIMessage.user('今天有什么新闻？')],
  tools: [OpenAITool.webSearch()],
));
```

### 语音合成 (TTS)

```dart
final audioBytes = await client.tts(
  input: '你好，这是 MiMo 语音合成。',
  voice: TtsVoice.mimoDefault,
  format: TtsAudioFormat.wav,
);

await File('output.wav').writeAsBytes(audioBytes);
```

### 思考模式

```dart
// OpenAI
final response = await client.chat(OpenAIChatRequest(
  model: MimoModel.mimoV2Pro.id,
  messages: [OpenAIMessage.user('25 * 47 等于多少？')],
  thinking: OpenAIThinkingConfig.enabled(),
));

final message = response.choices.first.message;
if (message.reasoningContent != null) {
  print('思考过程: ${message.reasoningContent}');
}
print('回答: ${message.content}');

// Anthropic
final response = await client.messages(AnthropicMessagesRequest(
  model: MimoModel.mimoV2Pro.id,
  maxTokens: 2048,
  messages: [AnthropicMessage.user('25 * 47 等于多少？')],
  thinking: AnthropicThinkingConfig.enabled(budgetTokens: 1024),
));
```

### 结构化输出

```dart
final response = await client.chat(OpenAIChatRequest(
  model: MimoModel.mimoV2Pro.id,
  messages: [
    OpenAIMessage.user(
      '列出 3 种编程语言，返回 JSON：'
      '{"languages": [{"name": "...", "year": 1990}]}',
    ),
  ],
  responseFormat: OpenAIResponseFormat.jsonObject(),
));
```

## 配置

```dart
final client = MimoClient(
  config: MimoClientConfig(
    apiKey: 'your-api-key',
    baseUrl: 'https://api.xiaomimimo.com',  // 默认值
    defaultFormat: MimoApiFormat.openai,      // 默认值
    connectTimeout: Duration(seconds: 30),    // 默认值
    receiveTimeout: Duration(seconds: 120),   // 默认值
    headers: {'X-Custom': 'value'},           // 可选
    httpClient: customHttpClient,             // 可选
  ),
);
```

## 错误处理

所有 API 错误均为 `MimoException` 的子类，按 HTTP 状态码分类：

```dart
try {
  final response = await client.chat(request);
} on MimoAuthenticationException catch (e) {
  // 401 — API key 无效
} on MimoRateLimitException catch (e) {
  // 429 — 触发限流，e.retryAfter 包含建议重试间隔
} on MimoApiException catch (e) {
  // 400/403 — 请求参数有误
} on MimoServerException catch (e) {
  // 5xx — 服务端异常
} on MimoNetworkException catch (e) {
  // 网络不通
} on MimoException catch (e) {
  // 其他未预期的错误
}
```

## 环境要求

- Dart SDK >= 3.0.0
- 有效的 Xiaomi MIMO API key，前往 [platform.xiaomimimo.com](https://platform.xiaomimimo.com/) 获取

## 许可证

MIT
