import 'dart:io';

import 'package:mimo_flutter_sdk_community/mimo_flutter_sdk_community.dart';

Future<void> main() async {
  final apiKey = Platform.environment['MIMO_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('Error: Set MIMO_API_KEY environment variable.');
    exit(1);
  }

  final client = MimoClient(
    config: MimoClientConfig(apiKey: apiKey),
  );

  try {
    await openaiChat(client);
    await openaiStreamChat(client);
    await anthropicChat(client);
    await anthropicStreamChat(client);
    await openaiToolUse(client);
    await openaiWebSearch(client);
    await openaiMultimodal(client);
    await openaiTts(client);
    await openaiThinking(client);
    await anthropicThinking(client);
    await anthropicToolUse(client);
    await openaiStructuredOutput(client);
    errorHandling();
    configuration();
  } on MimoException catch (e) {
    stderr.writeln('API error: $e');
  } finally {
    client.dispose();
  }
}

/// OpenAI 格式 — 非流式对话
Future<void> openaiChat(MimoClient client) async {
  print('=== OpenAI Chat ===');

  final response = await client.chat(
    OpenAIChatRequest(
      model: MimoModel.mimoV2Pro.id,
      messages: [
        OpenAIMessage.system('你是一个简洁的助手。'),
        OpenAIMessage.user('用一句话介绍自己'),
      ],
      temperature: 0.7,
      maxCompletionTokens: 256,
    ),
  );

  final choice = response.choices.first;
  print('assistant: ${choice.message.content}');
  print('tokens: ${response.usage?.totalTokens}');
  print('');
}

/// OpenAI 格式 — 流式对话
Future<void> openaiStreamChat(MimoClient client) async {
  print('=== OpenAI Streaming ===');

  final stream = client.chatStream(
    OpenAIChatRequest(
      model: MimoModel.mimoV2Pro.id,
      messages: [OpenAIMessage.user('数 1 到 5，每个数一行')],
      maxCompletionTokens: 64,
    ),
  );

  stdout.write('assistant: ');
  await for (final chunk in stream) {
    if (chunk.choices.isEmpty) continue;
    final delta = chunk.choices.first.delta;
    if (delta.content != null) {
      stdout.write(delta.content);
    }
  }
  print('\n');
}

/// Anthropic 格式 — 非流式对话
Future<void> anthropicChat(MimoClient client) async {
  print('=== Anthropic Chat ===');

  final response = await client.messages(
    AnthropicMessagesRequest(
      model: MimoModel.mimoV2Pro.id,
      maxTokens: 256,
      system: '你是一个简洁的助手。',
      messages: [AnthropicMessage.user('用一句话介绍自己')],
      temperature: 0.7,
    ),
  );

  final textBlock = response.content.whereType<AnthropicTextContent>().first;
  print('assistant: ${textBlock.text}');
  print('tokens: ${response.usage?.outputTokens}');
  print('');
}

/// Anthropic 格式 — 流式对话
Future<void> anthropicStreamChat(MimoClient client) async {
  print('=== Anthropic Streaming ===');

  final stream = client.messagesStream(
    AnthropicMessagesRequest(
      model: MimoModel.mimoV2Pro.id,
      maxTokens: 64,
      messages: [AnthropicMessage.user('数 1 到 5，每个数一行')],
    ),
  );

  stdout.write('assistant: ');
  await for (final event in stream) {
    if (event is AnthropicContentBlockDeltaEvent) {
      final delta = event.delta;
      if (delta is AnthropicTextDelta) {
        stdout.write(delta.text);
      }
    }
  }
  print('\n');
}

/// OpenAI 格式 — 工具调用 (Function Calling)
Future<void> openaiToolUse(MimoClient client) async {
  print('=== OpenAI Tool Use ===');

  final response = await client.chat(
    OpenAIChatRequest(
      model: MimoModel.mimoV2Pro.id,
      messages: [OpenAIMessage.user('北京今天天气怎么样？')],
      tools: [
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
      ],
      toolChoice: const OpenAIToolChoice.auto(),
      maxCompletionTokens: 256,
    ),
  );

  final choice = response.choices.first;
  if (choice.message.toolCalls != null) {
    for (final call in choice.message.toolCalls!) {
      print('tool call: ${call.function.name}(${call.function.parsedArguments})');
    }
  } else {
    print('assistant: ${choice.message.content}');
  }
  print('');
}

/// OpenAI 格式 — Web Search
Future<void> openaiWebSearch(MimoClient client) async {
  print('=== OpenAI Web Search ===');

  final response = await client.chat(
    OpenAIChatRequest(
      model: MimoModel.mimoV2Pro.id,
      messages: [OpenAIMessage.user('今天有什么重要新闻？')],
      tools: [OpenAITool.webSearch()],
      maxCompletionTokens: 512,
    ),
  );

  print('assistant: ${response.choices.first.message.content}');
  print('');
}

/// OpenAI 格式 — 图片理解 (Multimodal)
Future<void> openaiMultimodal(MimoClient client) async {
  print('=== OpenAI Multimodal ===');

  // Image URL
  final response = await client.chat(
    OpenAIChatRequest(
      model: MimoModel.mimoV2Omni.id,
      messages: [
        OpenAIMessage.userContent([
          OpenAIMessageContent.text('描述这张图片'),
          OpenAIMessageContent.imageUrl('https://example.com/photo.jpg'),
        ]),
      ],
      maxCompletionTokens: 256,
    ),
  );

  print('assistant: ${response.choices.first.message.content}');

  // Base64 image（需要先读取本地文件）
  // final base64Data = base64Encode(await File('photo.png').readAsBytes());
  // final response2 = await client.chat(
  //   OpenAIChatRequest(
  //     model: MimoModel.mimoV2Omni.id,
  //     messages: [
  //       OpenAIMessage.userContent([
  //         OpenAIMessageContent.text('描述这张图片'),
  //         OpenAIMessageContent.imageBase64(base64Data, 'image/png'),
  //       ]),
  //     ],
  //     maxCompletionTokens: 256,
  //   ),
  // );
  print('');
}

/// OpenAI 格式 — 文字转语音 (TTS)
Future<void> openaiTts(MimoClient client) async {
  print('=== OpenAI TTS ===');

  final audioBytes = await client.tts(
    input: '你好，这是 MiMo 语音合成示例。',
    voice: TtsVoice.mimoDefault,
    format: TtsAudioFormat.wav,
  );

  await File('output.wav').writeAsBytes(audioBytes);
  print('Audio saved to output.wav (${audioBytes.length} bytes)');
  print('');
}

/// OpenAI 格式 — 思考模式 (Thinking Mode)
Future<void> openaiThinking(MimoClient client) async {
  print('=== OpenAI Thinking ===');

  final response = await client.chat(
    OpenAIChatRequest(
      model: MimoModel.mimoV2Pro.id,
      messages: [OpenAIMessage.user('25 * 47 等于多少？请逐步推理。')],
      thinking: OpenAIThinkingConfig.enabled(),
      maxCompletionTokens: 1024,
    ),
  );

  final message = response.choices.first.message;
  if (message.reasoningContent != null) {
    print('thinking: ${message.reasoningContent}');
  }
  print('assistant: ${message.content}');
  print('');
}

/// Anthropic 格式 — 思考模式 (Thinking Mode)
Future<void> anthropicThinking(MimoClient client) async {
  print('=== Anthropic Thinking ===');

  final response = await client.messages(
    AnthropicMessagesRequest(
      model: MimoModel.mimoV2Pro.id,
      maxTokens: 2048,
      messages: [AnthropicMessage.user('25 * 47 等于多少？请逐步推理。')],
      thinking: AnthropicThinkingConfig.enabled(budgetTokens: 1024),
    ),
  );

  for (final block in response.content) {
    if (block is AnthropicThinkingContent) {
      print('thinking: ${block.thinking}');
    } else if (block is AnthropicTextContent) {
      print('assistant: ${block.text}');
    }
  }
  print('');
}

/// Anthropic 格式 — 工具调用 (Function Calling)
Future<void> anthropicToolUse(MimoClient client) async {
  print('=== Anthropic Tool Use ===');

  final response = await client.messages(
    AnthropicMessagesRequest(
      model: MimoModel.mimoV2Pro.id,
      maxTokens: 256,
      messages: [AnthropicMessage.user('北京今天天气怎么样？')],
      tools: [
        const AnthropicTool(
          name: 'get_weather',
          description: '获取指定城市的当前天气',
          inputSchema: {
            'type': 'object',
            'properties': {
              'city': {'type': 'string', 'description': '城市名称'},
            },
            'required': ['city'],
          },
        ),
      ],
      toolChoice: const AnthropicToolChoice.auto(),
    ),
  );

  for (final block in response.content) {
    if (block is AnthropicToolUseContent) {
      print('tool call: ${block.name}(${block.input})');
    } else if (block is AnthropicTextContent) {
      print('assistant: ${block.text}');
    }
  }
  print('');
}

/// OpenAI 格式 — 结构化输出 (Structured Output)
Future<void> openaiStructuredOutput(MimoClient client) async {
  print('=== OpenAI Structured Output ===');

  final response = await client.chat(
    OpenAIChatRequest(
      model: MimoModel.mimoV2Pro.id,
      messages: [
        OpenAIMessage.user(
          '列出 3 种编程语言。返回 JSON: '
          '{"languages": [{"name": "...", "year": 1990}]}',
        ),
      ],
      responseFormat: const OpenAIResponseFormat.jsonObject(),
      maxCompletionTokens: 256,
    ),
  );

  final content = response.choices.first.message.content;
  print('assistant: $content');
  print('');
}

/// 错误处理 — 各异常类型的 catch 示例
void errorHandling() {
  print('=== Error Handling ===');

  // 演示各异常类型的捕获方式
  try {
    throw const MimoAuthenticationException('Invalid API key');
  } on MimoAuthenticationException catch (e) {
    print('MimoAuthenticationException: ${e.message}');
  }

  try {
    throw const MimoRateLimitException(
      'Rate limited',
      retryAfter: Duration(seconds: 60),
    );
  } on MimoRateLimitException catch (e) {
    print('MimoRateLimitException: ${e.message}, retryAfter: ${e.retryAfter}');
  }

  try {
    throw const MimoApiException('Bad request', statusCode: 400);
  } on MimoApiException catch (e) {
    print('MimoApiException: ${e.message} (${e.statusCode})');
  }

  try {
    throw const MimoServerException('Internal server error', statusCode: 500);
  } on MimoServerException catch (e) {
    print('MimoServerException: ${e.message} (${e.statusCode})');
  }

  try {
    throw const MimoNetworkException('Connection timeout');
  } on MimoNetworkException catch (e) {
    print('MimoNetworkException: ${e.message}');
  }

  print('');
}

/// 配置 — MimoClientConfig 全参数展示
void configuration() {
  print('=== Configuration ===');

  // 全参数配置示例
  final _ = MimoClientConfig(
    apiKey: 'your-api-key',
    baseUrl: 'https://api.xiaomimimo.com',
    defaultFormat: MimoApiFormat.openai,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 120),
    headers: {'X-Custom': 'value'},
    // httpClient: customHttpClient, // 可选：自定义 HTTP client
  );

  print('MimoClientConfig created with all parameters');
  print('');
}
