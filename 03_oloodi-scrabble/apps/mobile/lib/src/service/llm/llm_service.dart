import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/constants/llm_config.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/move.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/settings_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/service/llm/exceptions/llm_provider_exception.dart';
import './base_llm_provider.dart';
import './llm_provider_factory.dart';

class LLMService {
  BaseLLMProvider? _currentProvider;
  final SettingsProvider _settings;

  LLMService(this._settings) {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    try {
      final config = await _loadProviderConfig(_settings.llmProvider);
      _currentProvider = LLMProviderFactory.createProvider(
        _settings.llmProvider,
        config,
      );
      await _currentProvider?.initialize();
    } catch (e) {
      debugPrint('Error initializing provider: $e');
      throw LLMProviderException('Failed to initialize provider: $e');
    }
  }

  Future<Map<String, dynamic>> _loadProviderConfig(LLMProvider provider) async {
    // Load provider-specific configuration
    switch (provider) {
      case LLMProvider.gemini:
        return {
          'model': LLMConfig.geminiModelName,
        };

      case LLMProvider.claude:
        // Load Claude API key from secure storage or environment
        const apiKey = String.fromEnvironment(LLMConfig.claudeApiKeyEnv);
        if (apiKey.isEmpty) {
          throw LLMProviderException('Claude API key not found');
        }
        return {
          'apiKey': apiKey,
          'apiEndpoint': const String.fromEnvironment(
            LLMConfig.claudeApiEndpointEnv,
            defaultValue: LLMConfig.claudeDefaultEndpoint,
          ),
        };
      case LLMProvider.deepseek:
        return {
          'apiKey': const String.fromEnvironment(LLMConfig.deepseekApiKeyEnv),
        };

      case LLMProvider.o3:
        return {
          'apiKey': const String.fromEnvironment(LLMConfig.o3ApiKeyEnv),
        };
    }
  }

  Future<String> generateMoveExplanation(
    String playerName,
    Move move,
    int currentScore,
  ) async {
    if (_currentProvider == null) {
      throw LLMProviderException('No LLM provider initialized');
    }

    try {
      return await _currentProvider!.generateMoveExplanation(
        playerName,
        move,
        currentScore,
        _settings.language,
      );
    } catch (e) {
      throw LLMProviderException('Failed to generate explanation: $e');
    }
  }

  Future<void> switchProvider(LLMProvider newProvider) async {
    try {
      // 1. Dispose of the current provider
      await _currentProvider?.dispose();

      // 2. Load configuration for the new provider
      final config = await _loadProviderConfig(newProvider);

      // 3. Create and initialize the new provider
      _currentProvider = LLMProviderFactory.createProvider(newProvider, config);
      await _currentProvider?.initialize();

      debugPrint('Successfully switched to ${newProvider.toString()}');
    } catch (e) {
      debugPrint('Error switching provider: $e');
      // Re-initialize the previous provider if switch fails
      await _initializeProvider();
      throw LLMProviderException('Failed to switch provider: $e');
    }
  }

  Future<void> dispose() async {
    await _currentProvider?.dispose();
    _currentProvider = null;
  }
}
