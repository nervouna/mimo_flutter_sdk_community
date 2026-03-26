/// Xiaomi MIMO LLM API client for Dart and Flutter.
///
/// Supports OpenAI-compatible and Anthropic-compatible endpoints,
/// streaming, tool use, multimodal inputs, TTS, and thinking mode.
library mimo_flutter_sdk_community;

// Client
export 'src/client/client_config.dart';
export 'src/client/mimo_client.dart';

// Common enums
export 'src/models/common.dart';

// OpenAI models
export 'src/models/openai/openai_chunk.dart';
export 'src/models/openai/openai_content.dart';
export 'src/models/openai/openai_request.dart';
export 'src/models/openai/openai_response.dart';
export 'src/models/openai/openai_tool.dart';

// Anthropic models
export 'src/models/anthropic/anthropic_chunk.dart';
export 'src/models/anthropic/anthropic_content.dart';
export 'src/models/anthropic/anthropic_request.dart';
export 'src/models/anthropic/anthropic_response.dart';
export 'src/models/anthropic/anthropic_tool.dart';

// Errors
export 'src/errors/mimo_exception.dart';

// Utils
export 'src/utils/json_extractor.dart';

// Transport
export 'src/transport/anthropic_sse_data.dart';

// Services (advanced usage)
export 'src/services/openai_service.dart';
export 'src/services/anthropic_service.dart';
