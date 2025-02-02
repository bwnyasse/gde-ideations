import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/move.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/settings_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/service/llm/llm_service.dart';

class AIService {
  final LLMService _llmService;
  bool _isTtsInitialized = false;

  AIService(SettingsProvider settings) : _llmService = LLMService(settings) {
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    try {
      TtsGoogle.init(
        apiKey: const String.fromEnvironment('GOOGLE_CLOUD_API_KEY'),
        withLogs: true,
      );
      _isTtsInitialized = true;
      debugPrint('TTS initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize TTS: $e');
      _isTtsInitialized = false;
    }
  }

  Future<String> generateMoveExplanation(
    String playerName,
    Move move,
    int currentScore,
  ) async {
    return _llmService.generateMoveExplanation(playerName, move, currentScore);
  }

  Future<void> switchProvider(LLMProvider newProvider) async {
    await _llmService.switchProvider(newProvider);
  }

  Future<List<int>> convertToSpeech(String text, AppLanguage language) async {
    if (!_isTtsInitialized) {
      debugPrint('TTS not initialized, attempting to initialize...');
      await _initializeTts();
      if (!_isTtsInitialized) {
        throw Exception('Failed to initialize Text-to-Speech service');
      }
    }
    try {
      debugPrint('Fetching available voices...');
      final voicesResponse = await TtsGoogle.getVoices();

      if (voicesResponse.voices.isEmpty) {
        throw Exception('No voices available');
      }

  //     debugPrint('Available Voices:');
  //     for (final voice in voicesResponse.voices) {
  //       debugPrint('''
  //   Code: ${voice.code}
  //   Voice Type: ${voice.voiceType}
  //   Name: ${voice.name}
  //   Native Name: ${voice.nativeName}
  //   Gender: ${voice.gender}
  //   Locale: ${voice.locale.code}
  //   Sample Rate: ${voice.sampleRateHertz}
  //   -------------------------------------
  // ''');
  //     }

      // Define the voice parameters based on language
      final targetVoice = language == AppLanguage.english
          ? 'en-US-Wavenet-I' // English male voice
          : 'fr-FR-Wavenet-D'; // French male voice

      debugPrint('Looking for voice: $targetVoice');

      // Find the matching voice
      final voice = voicesResponse.voices
          .where((element) => element.code == targetVoice)
          .toList(growable: false)
          .firstOrNull;

      if (voice == null) {
        throw Exception('Selected voice not found: $targetVoice');
      }

      debugPrint('Converting text to speech with voice: ${voice.name}');

      TtsParamsGoogle params = TtsParamsGoogle(
        voice: voice,
        audioFormat: AudioOutputFormatGoogle.linear16,
        text: text,
      );

      final ttsResponse = await TtsGoogle.convertTts(params);

      if (ttsResponse.audio.buffer.lengthInBytes == 0) {
        throw Exception('Received empty audio data from TTS service');
      }
      debugPrint(
          'Successfully generated audio data: ${ttsResponse.audio.buffer.lengthInBytes} bytes');

      return ttsResponse.audio.buffer.asUint8List().toList();
    } catch (e) {
      debugPrint('TTS Error: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _llmService.dispose();
  }
}
