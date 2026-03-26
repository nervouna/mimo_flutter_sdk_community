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
