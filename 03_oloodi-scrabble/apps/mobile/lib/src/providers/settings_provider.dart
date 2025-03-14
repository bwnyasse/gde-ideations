// lib/src/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, french }

enum LLMProvider { gemini, claude, deepseek, o3 }

enum VoiceSynthesisProvider { cloudTts, elevenLabs }

enum AppThemeMode { dark, light, nature }

class SettingsProvider with ChangeNotifier {
  final SharedPreferences _prefs;

  VoidCallback? _onProviderChanged;

  // Default values
  AppLanguage _language = AppLanguage.english;
  LLMProvider _llmProvider = LLMProvider.gemini;
  VoiceSynthesisProvider _voiceProvider = VoiceSynthesisProvider.cloudTts;
  AppThemeMode _themeMode = AppThemeMode.dark;
  String _selectedVoice = 'Mason';

  // Keys for SharedPreferences
  static const String _llmProviderKey = 'llm_provider';
  static const String _voiceProviderKey = 'voice_provider';
  static const String _themeModeKey = 'theme_mode';
  static const String _selectedVoiceKey = 'selected_voice';
  static const String _languageKey = 'app_language';

  SettingsProvider(this._prefs) {
    _loadSettings();
  }

  // Getters
  AppLanguage get language => _language;
  LLMProvider get llmProvider => _llmProvider;
  VoiceSynthesisProvider get voiceProvider => _voiceProvider;
  AppThemeMode get themeMode => _themeMode;
  String get selectedVoice => _selectedVoice;

  // Add method to set the callback
  void setProviderChangedCallback(VoidCallback callback) {
    _onProviderChanged = callback;
  }

  // Load settings from SharedPreferences
  void _loadSettings() {
    final languageIndex = _prefs.getInt(_languageKey);
    if (languageIndex != null) {
      _language = AppLanguage.values[languageIndex];
    }

    final llmIndex = _prefs.getInt(_llmProviderKey);
    if (llmIndex != null) {
      _llmProvider = LLMProvider.values[llmIndex];
    }

    final voiceProviderIndex = _prefs.getInt(_voiceProviderKey);
    if (voiceProviderIndex != null) {
      _voiceProvider = VoiceSynthesisProvider.values[voiceProviderIndex];
    }

    final themeModeIndex = _prefs.getInt(_themeModeKey);
    if (themeModeIndex != null) {
      _themeMode = AppThemeMode.values[themeModeIndex];
    }

    _selectedVoice = _prefs.getString(_selectedVoiceKey) ?? _selectedVoice;
  }

  Future<void> setLanguage(AppLanguage language) async {
    _language = language;
    await _prefs.setInt(_languageKey, language.index);
    notifyListeners();
  }

  // Setters with persistence
  Future<void> setLLMProvider(LLMProvider provider) async {
    try {
      // Update local state and preferences
      _llmProvider = provider;
      await _prefs.setInt(_llmProviderKey, provider.index);

      // Notify the callback if set
      _onProviderChanged?.call();

      // Notify listeners of the change
      notifyListeners();
    } catch (e) {
      // Handle any errors during provider switch
      debugPrint('Error switching LLM provider: $e');
      // You might want to show an error message to the user
      rethrow;
    }
  }

  Future<void> setVoiceProvider(VoiceSynthesisProvider provider) async {
    _voiceProvider = provider;
    await _prefs.setInt(_voiceProviderKey, provider.index);
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }

  Future<void> setSelectedVoice(String voice) async {
    _selectedVoice = voice;
    await _prefs.setString(_selectedVoiceKey, voice);
    notifyListeners();
  }

  // Helper methods for UI
  String getLLMProviderName(LLMProvider provider) {
    switch (provider) {
      case LLMProvider.gemini:
        return 'Google Gemini';
      case LLMProvider.claude:
        return 'Anthropic Claude';
      case LLMProvider.deepseek:
        return 'DeepSeek';
      case LLMProvider.o3:
        return 'O3 AI';
    }
  }

  String getVoiceProviderName(VoiceSynthesisProvider provider) {
    switch (provider) {
      case VoiceSynthesisProvider.cloudTts:
        return 'Google Cloud TTS';
      case VoiceSynthesisProvider.elevenLabs:
        return 'ElevenLabs';
    }
  }

  List<String> getAvailableVoices() {
    switch (_voiceProvider) {
      case VoiceSynthesisProvider.cloudTts:
        return ['Mason', 'Grace', 'Alex', 'Sarah'];
      case VoiceSynthesisProvider.elevenLabs:
        return ['Rachel', 'Michael', 'Emily', 'Josh'];
    }
  }
}
