// lib/config/env_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get geminiApiKey {
    try {
      return dotenv.get('GEMINI_API_KEY', fallback: '');
    } catch (e) {
      return '';
    }
  }

  static String get elevenLabsApiKey {
    try {
      return dotenv.get('ELEVEN_LABS_API_KEY', fallback: '');
    } catch (e) {
      return '';
    }
  }

  static String get elevenLabsVoiceId {
    try {
      return dotenv.get('ELEVEN_LABS_VOICE_ID', fallback: '');
    } catch (e) {
      return '';
    }
  }

  static bool get isConfigured {
    return geminiApiKey.isNotEmpty && 
           elevenLabsApiKey.isNotEmpty && 
           elevenLabsVoiceId.isNotEmpty;
  }

  static List<String> getMissingConfigurations() {
    final missing = <String>[];
    
    if (geminiApiKey.isEmpty) {
      missing.add('Gemini API Key');
    }
    if (elevenLabsApiKey.isEmpty) {
      missing.add('ElevenLabs API Key');
    }
    if (elevenLabsVoiceId.isEmpty) {
      missing.add('ElevenLabs Voice ID');
    }
    
    return missing;
  }
}