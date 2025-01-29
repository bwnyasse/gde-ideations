import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:oloodi_scrabble_moderator_app/src/config/env_config.dart';
import 'package:oloodi_scrabble_moderator_app/src/services/firebase_service.dart';

class GeminiService {
  late GenerativeModel _model;
  final FirebaseService _firebaseService = FirebaseService();

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: 'AIzaSyAMRHzq6_i_jVDUfxOooscv5riCNIxqyXQ',
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
    );
  }

  Future<Map<String, dynamic>> analyzeBoardImage(
    String sessionId,
    String imagePath,
  ) async {
    try {
      // Get previous board state
      final boardState = await _firebaseService.getBoardState(sessionId).first;
      final isFirstMove = boardState.isEmpty;

      // Read image bytes
      final imageBytes = await File(imagePath).readAsBytes();

      // Construct prompt based on whether it's first move or subsequent move
      final prompt = isFirstMove
          ? _constructInitialBoardPrompt()
          : _constructDeltaAnalysisPrompt(boardState);

      // Send request to Gemini
      final response = await _model.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);

      if (response.text == null) {
        throw Exception('Empty response from Gemini');
      }

      // Parse and validate response
      return _parseGeminiResponse(response.text!, isFirstMove);
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  String _constructInitialBoardPrompt() {
    return '''
    Analyze this Scrabble board image and identify all letters and their positions.
    Return a JSON object with the following structure:
    {
      "board": [
        {
          "letter": "A",
          "row": 7,
          "col": 7,
          "points": 1
        },
        ...
      ]
    }
    Important:
    - Row and column indices are 0-based (0-14)
    - Include letter points according to Scrabble rules
    - Only include placed letters, not empty squares
    - Ensure coordinates are within the 15x15 grid
    ''';
  }

  String _constructDeltaAnalysisPrompt(Map<String, dynamic> previousState) {
    return '''
    Compare this Scrabble board image with the previous state and identify newly placed letters.
    Previous board state: ${jsonEncode(previousState)}
    
    Return a JSON object with the following structure:
    {
      "word": "EXAMPLE",
      "score": 15,
      "tiles": [
        {
          "letter": "A",
          "row": 7,
          "col": 7,
          "points": 1
        },
        ...
      ]
    }
    Important:
    - Only include NEW letters placed in this move
    - Calculate word score including multipliers
    - Return complete words formed by the new letters
    - Ensure coordinates are within the 15x15 grid
    ''';
  }

  Map<String, dynamic> _parseGeminiResponse(String response, bool isFirstMove) {
    try {
      String cleanJson = response
          .replaceAll('```json', '') // Remove ```json
          .replaceAll('```', '') // Remove remaining ```
          .trim(); // Remove any extra whitespace
      final jsonResponse = jsonDecode(cleanJson);

      // Validate response structure
      if (isFirstMove) {
        _validateInitialResponse(jsonResponse);
        return {
          'status': 'success',
          'type': 'initial',
          'data': jsonResponse,
        };
      } else {
        _validateDeltaResponse(jsonResponse);
        return {
          'status': 'success',
          'type': 'move',
          'data': jsonResponse,
        };
      }
    } catch (e) {
      throw Exception('Invalid response format: $e');
    }
  }

  void _validateInitialResponse(Map<String, dynamic> response) {
    if (!response.containsKey('board')) {
      throw Exception('Missing board data in response');
    }

    final board = response['board'] as List;
    for (var tile in board) {
      if (!tile.containsKey('letter') ||
          !tile.containsKey('row') ||
          !tile.containsKey('col') ||
          !tile.containsKey('points')) {
        throw Exception('Invalid tile data in response');
      }

      // Validate coordinates
      final row = tile['row'] as int;
      final col = tile['col'] as int;
      if (row < 0 || row > 14 || col < 0 || col > 14) {
        throw Exception('Invalid coordinates in response');
      }
    }
  }

  void _validateDeltaResponse(Map<String, dynamic> response) {
    if (!response.containsKey('word') ||
        !response.containsKey('score') ||
        !response.containsKey('tiles')) {
      throw Exception('Missing required fields in response');
    }

    final tiles = response['tiles'] as List;
    for (var tile in tiles) {
      if (!tile.containsKey('letter') ||
          !tile.containsKey('row') ||
          !tile.containsKey('col') ||
          !tile.containsKey('points')) {
        throw Exception('Invalid tile data in response');
      }

      // Validate coordinates
      final row = tile['row'] as int;
      final col = tile['col'] as int;
      if (row < 0 || row > 14 || col < 0 || col > 14) {
        throw Exception('Invalid coordinates in response');
      }
    }
  }
}
