// lib/src/constants/llm_config.dart
class LLMConfig {
  // Gemini configuration
  static const String geminiModelName = 'gemini-2.0-flash-exp';

  // API endpoints
  static const String claudeDefaultEndpoint = 'https://api.anthropic.com/v1/messages';
  
  // Environment variable keys
  static const String claudeApiKeyEnv = 'CLAUDE_API_KEY';
  static const String claudeApiEndpointEnv = 'CLAUDE_API_ENDPOINT';
  static const String deepseekApiKeyEnv = 'DEEPSEEK_API_KEY';
  static const String o3ApiKeyEnv = 'O3_API_KEY';
}