import 'package:mimo_flutter_sdk_community/mimo_flutter_sdk_community.dart';
import 'package:test/test.dart';

void main() {
  group('MimoApiFormat', () {
    test('values contains openai and anthropic', () {
      expect(MimoApiFormat.values, hasLength(2));
      expect(MimoApiFormat.openai.name, 'openai');
      expect(MimoApiFormat.anthropic.name, 'anthropic');
    });
  });

  group('MimoModel', () {
    test('each model has correct id string', () {
      expect(MimoModel.mimoV2Pro.id, 'mimo-v2-pro');
      expect(MimoModel.mimoV2Omni.id, 'mimo-v2-omni');
      expect(MimoModel.mimoV2Flash.id, 'mimo-v2-flash');
      expect(MimoModel.mimoV2Tts.id, 'mimo-v2-tts');
    });
  });

  group('ThinkingMode', () {
    test('enabled has value "enabled"', () {
      expect(ThinkingMode.enabled.value, 'enabled');
    });
    test('disabled has value "disabled"', () {
      expect(ThinkingMode.disabled.value, 'disabled');
    });
  });

  group('TtsVoice', () {
    test('each voice has correct value', () {
      expect(TtsVoice.mimoDefault.value, 'mimo_default');
      expect(TtsVoice.defaultZh.value, 'default_zh');
      expect(TtsVoice.defaultEn.value, 'default_en');
    });
  });

  group('TtsAudioFormat', () {
    test('wav has value "wav"', () {
      expect(TtsAudioFormat.wav.value, 'wav');
    });
    test('pcm16 has value "pcm16"', () {
      expect(TtsAudioFormat.pcm16.value, 'pcm16');
    });
  });

  group('FinishReason', () {
    test('each reason has correct value', () {
      expect(FinishReason.stop.value, 'stop');
      expect(FinishReason.length.value, 'length');
      expect(FinishReason.toolCalls.value, 'tool_calls');
      expect(FinishReason.contentFilter.value, 'content_filter');
      expect(FinishReason.endTurn.value, 'end_turn');
      expect(FinishReason.maxTokens.value, 'max_tokens');
    });

    test('fromString returns correct reason for known values', () {
      expect(FinishReason.fromString('stop'), FinishReason.stop);
      expect(FinishReason.fromString('length'), FinishReason.length);
      expect(FinishReason.fromString('tool_calls'), FinishReason.toolCalls);
      expect(FinishReason.fromString('content_filter'), FinishReason.contentFilter);
      expect(FinishReason.fromString('end_turn'), FinishReason.endTurn);
      expect(FinishReason.fromString('max_tokens'), FinishReason.maxTokens);
    });

    test('fromString returns null for unknown value', () {
      expect(FinishReason.fromString('bogus'), isNull);
    });

    test('fromString returns null for null input', () {
      expect(FinishReason.fromString(null), isNull);
    });
  });
}
