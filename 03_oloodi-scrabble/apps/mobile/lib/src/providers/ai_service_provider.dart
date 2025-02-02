import 'package:flutter/foundation.dart';
import 'package:oloodi_scrabble_end_user_app/src/service/ai_service.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/settings_provider.dart';

class AIServiceProvider extends ChangeNotifier {
  late final AIService _aiService;
  late final SettingsProvider _settings;

  AIServiceProvider(SettingsProvider settings) {
    _settings = settings;
    _aiService = AIService(settings);

    // Set up the callback
    settings.setProviderChangedCallback(() {
      _handleProviderChanged();
    });
  }

  Future<void> _handleProviderChanged() async {
    try {
      await _aiService.switchProvider(_settings.llmProvider);
      notifyListeners();
    } catch (e) {
      debugPrint('Error handling provider change: $e');
      rethrow;
    }
  }

  AIService get service => _aiService;

  // Expose switchProvider method
  Future<void> switchProvider(LLMProvider newProvider) async {
    try {
      await _aiService.switchProvider(newProvider);
      notifyListeners();
    } catch (e) {
      debugPrint('Error in AIServiceProvider switchProvider: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _aiService.dispose();
    super.dispose();
  }
}
