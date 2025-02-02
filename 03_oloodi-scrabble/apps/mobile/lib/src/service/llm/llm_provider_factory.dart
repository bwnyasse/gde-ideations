import 'package:oloodi_scrabble_end_user_app/src/providers/settings_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/service/llm/base_llm_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/service/llm/providers/claude_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/service/llm/providers/gemini_provider.dart';

class LLMProviderFactory {
  static BaseLLMProvider createProvider(
      LLMProvider provider, Map<String, dynamic> config) {
    switch (provider) {
      case LLMProvider.gemini:
        return GeminiProvider(config: config);
      case LLMProvider.claude:
        return ClaudeProvider(
          apiKey: config['apiKey'] as String,
          apiEndpoint: config['apiEndpoint'] as String?,
        );
      case LLMProvider.deepseek:
        // TODO: Implement DeepSeek provider
        throw UnimplementedError('DeepSeek provider not yet implemented');
      case LLMProvider.o3:
        // TODO: Implement O3 provider
        throw UnimplementedError('O3 provider not yet implemented');
    }
  }
}
