import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/service/llm/exceptions/llm_provider_exception.dart';
import '../../../models/move.dart';
import '../base_llm_provider.dart';

class GeminiProvider extends BaseLLMProvider {
  GenerativeModel? _model;
  final String _modelName;

  GeminiProvider({
    required Map<String, dynamic> config,
  }) : _modelName = config['model'] as String;

  @override
  Future<void> initialize() async {
    if (_model != null) return;
    try {
      debugPrint('Initializing Gemini model with $_modelName');
      _model = FirebaseVertexAI.instance.generativeModel(model: _modelName);

      await _model?.generateContent([Content.text('test initialization')]);
      debugPrint('Gemini model initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Gemini model: $e');
      _model = null;
      rethrow;
    }
  }

  @override
  Future<String> generateMoveExplanation(
      String playerName, Move move, int currentScore) async {
    if (_model == null) {
      await initialize();
    }

    if (_model == null) {
      throw LLMProviderException('Gemini model not initialized');
    }
    try {
      final prompt = createPrompt(playerName, move, currentScore);

      final response = await _model!.generateContent([
        Content.multi([TextPart(prompt)]),
      ]);

      if (response.text == null) {
        throw LLMProviderException('Empty response from Gemini');
      }

      return _cleanMarkdownText(response.text!);
    } catch (e) {
      throw LLMProviderException('Failed to generate Gemini explanation: $e');
    }
  }

  @override
  Future<void> dispose() async {
    _model = null;
  }

  String _cleanMarkdownText(String markdown) {
    // Implementation remains the same as current AIService
    var cleaned = markdown.replaceAll(RegExp(r'#{1,6}\s.*\n'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\*\*|__|\*|_'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    cleaned = cleaned.replaceAll(RegExp(r'`[^`]*`'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'\[([^\]]*)\]\([^\)]*\)'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'^\s*[-*_]{3,}\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    return cleaned.trim();
  }
}
