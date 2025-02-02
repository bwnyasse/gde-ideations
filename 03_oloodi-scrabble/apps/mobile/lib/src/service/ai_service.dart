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

  Future<List<int>> convertToSpeech(String text) async {
    if (!_isTtsInitialized) {
      await _initializeTts();
      if (!_isTtsInitialized) {
        throw Exception('Failed to initialize Text-to-Speech service');
      }
    }

    final voicesResponse = await TtsGoogle.getVoices();

    final voice = voicesResponse.voices
        .where((element) => element.name.startsWith('Mason'))
        .toList(growable: false)
        .first;

    TtsParamsGoogle params = TtsParamsGoogle(
      voice: voice,
      audioFormat: AudioOutputFormatGoogle.linear16,
      text: text,
    );

    final ttsResponse = await TtsGoogle.convertTts(params);
    return ttsResponse.audio.buffer.asUint8List().toList();
  }

  Future<void> dispose() async {
    await _llmService.dispose();
  }
}
