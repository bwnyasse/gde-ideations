import 'package:http/http.dart' as http;
import 'package:oloodi_scrabble_end_user_app/src/models/move.dart';
import 'package:oloodi_scrabble_end_user_app/src/service/llm/exceptions/llm_provider_exception.dart';
import 'dart:convert';
import '../base_llm_provider.dart';

class ClaudeProvider extends BaseLLMProvider {
  final String _apiKey;
  final String _apiEndpoint;
  
  ClaudeProvider({
    required String apiKey,
    String? apiEndpoint,
  }) : _apiKey = apiKey,
       _apiEndpoint = apiEndpoint ?? 'https://api.anthropic.com/v1/messages';
  
  @override
  Future<void> initialize() async {
    // Validate API key and connection
    try {
      final response = await http.get(
        Uri.parse(_apiEndpoint),
        headers: {'X-API-Key': _apiKey},
      );
      
      if (response.statusCode != 200) {
        throw LLMProviderException('Failed to initialize Claude provider');
      }
    } catch (e) {
      throw LLMProviderException('Claude initialization error: $e');
    }
  }
  
  @override
  Future<String> generateMoveExplanation(
    String playerName, 
    Move move, 
    int currentScore
  ) async {
    try {
      final prompt = createPrompt(playerName, move, currentScore);
      
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey,
        },
        body: json.encode({
          'model': 'claude-3-sonnet-20240229',
          'messages': [{'role': 'user', 'content': prompt}],
          'max_tokens': 150,
        }),
      );
      
      if (response.statusCode != 200) {
        throw LLMProviderException('Claude API error: ${response.body}');
      }
      
      final data = json.decode(response.body);
      return data['content'] as String;
    } catch (e) {
      throw LLMProviderException('Failed to generate Claude explanation: $e');
    }
  }
  
  @override
  Future<void> dispose() async {
    // Clean up any resources if needed
  }
}