import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/env_config.dart';
import '../services/firebase_service.dart';

class GeminiService {
  late GenerativeModel _model;
  final FirebaseService _firebaseService = FirebaseService();

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: 'AIzaSyAMRHzq6_i_jVDUfxOooscv5riCNIxqyXQ',
      generationConfig: GenerationConfig(
        temperature: 0.7, // Reduced for more consistent outputs
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

      // Construct appropriate prompt
      final prompt = isFirstMove
          ? _constructInitialBoardPrompt()
          : _constructDeltaAnalysisPrompt(boardState);

      print('Sending prompt to Gemini: $prompt'); // Debug log

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

      print('Raw Gemini response: ${response.text}'); // Debug log

      // Parse and validate response
      return _parseGeminiResponse(response.text!, isFirstMove);
    } catch (e) {
      print('Error in analyzeBoardImage: $e'); // Debug log
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  String _constructInitialBoardPrompt() {
    return '''
You are analyzing a Scrabble board image for its initial state. I need you to:

1. Identify all visible letters on the board
2. Determine their exact positions (row and column, 0-14)
3. Assign correct point values based on Scrabble rules

Return ONLY a JSON object in exactly this format:
{
  "board": [
    {
      "letter": "A",
      "row": 7,
      "col": 7,
      "points": 1
    }
  ]
}

Rules to follow:
- Use 0-based indices (0-14) for rows and columns
- Include ONLY placed letters, ignore empty squares
- All coordinates must be within the 15x15 grid
- Do not include any explanatory text, ONLY the JSON
- Letter points must follow standard Scrabble rules

Point values reference:
A=1, B=3, C=3, D=2, E=1, F=4, G=2, H=4, I=1, J=8,
K=5, L=1, M=3, N=1, O=1, P=3, Q=10, R=1, S=1, T=1,
U=1, V=4, W=4, X=8, Y=4, Z=10
''';
  }

  String _constructDeltaAnalysisPrompt(Map<String, dynamic> previousState) {
    return '''
You are analyzing a Scrabble board to identify NEW letters played in the latest move.

Previous board state:
${jsonEncode(previousState)}

Return ONLY a JSON object in exactly this format:
{
  "word": "EXAMPLE",
  "score": 15,
  "newLetters": [
    {
      "letter": "A",
      "row": 7,
      "col": 7,
      "points": 1
    }
  ]
}

Rules to follow:
1. Include ONLY newly placed letters, not existing ones
2. Calculate the complete word formed by the new letters
3. Calculate the total score including:
   - Letter point values
   - Board multipliers (DL, TL, DW, TW)
4. Use 0-based indices (0-14) for rows and columns
5. Do not include any explanatory text, ONLY the JSON

Point values reference:
A=1, B=3, C=3, D=2, E=1, F=4, G=2, H=4, I=1, J=8,
K=5, L=1, M=3, N=1, O=1, P=3, Q=10, R=1, S=1, T=1,
U=1, V=4, W=4, X=8, Y=4, Z=10
''';
  }

  Map<String, dynamic> _parseGeminiResponse(String response, bool isFirstMove) {
    try {
      // Clean the response string
      String cleanJson = response
          .replaceAll(
              RegExp(r'```json\n?'), '') // Remove ```json with optional newline
          .replaceAll(RegExp(r'```\n?'), '') // Remove ``` with optional newline
          .trim(); // Remove extra whitespace

      print('Cleaned JSON string: $cleanJson'); // Debug log

      // Parse the cleaned JSON string
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
      print('Error parsing Gemini response: $e'); // Debug log
      throw Exception('Invalid response format: $e');
    }
  }

  void _validateInitialResponse(Map<String, dynamic> response) {
    if (!response.containsKey('board')) {
      throw Exception('Missing board data in response');
    }

    final board = response['board'];
    if (board is! List) {
      throw Exception('Board data is not a list');
    }

    for (var tile in board) {
      if (tile is! Map<String, dynamic>) {
        throw Exception('Invalid tile data format');
      }

      if (!tile.containsKey('letter') ||
          !tile.containsKey('row') ||
          !tile.containsKey('col') ||
          !tile.containsKey('points')) {
        throw Exception('Missing required tile fields');
      }

      // Validate data types and ranges
      if (tile['letter'] is! String || (tile['letter'] as String).isEmpty) {
        throw Exception('Invalid letter value');
      }

      final row = tile['row'];
      final col = tile['col'];
      if (row is! int ||
          col is! int ||
          row < 0 ||
          row > 14 ||
          col < 0 ||
          col > 14) {
        throw Exception('Invalid coordinates: row=$row, col=$col');
      }

      if (tile['points'] is! int || tile['points'] < 0) {
        throw Exception('Invalid points value');
      }
    }
  }

  void _validateDeltaResponse(Map<String, dynamic> response) {
    if (!response.containsKey('word') ||
        !response.containsKey('score') ||
        !response.containsKey('newLetters')) {
      throw Exception('Missing required fields in response');
    }

    if (response['word'] is! String || (response['word'] as String).isEmpty) {
      throw Exception('Invalid word value');
    }

    if (response['score'] is! int || response['score'] < 0) {
      throw Exception('Invalid score value');
    }

    final newLetters = response['newLetters'];
    if (newLetters is! List) {
      throw Exception('newLetters is not a list');
    }

    for (var tile in newLetters) {
      if (tile is! Map<String, dynamic>) {
        throw Exception('Invalid tile data format');
      }

      if (!tile.containsKey('letter') ||
          !tile.containsKey('row') ||
          !tile.containsKey('col') ||
          !tile.containsKey('points')) {
        throw Exception('Missing required tile fields');
      }

      // Validate data types and ranges
      if (tile['letter'] is! String || (tile['letter'] as String).isEmpty) {
        throw Exception('Invalid letter value');
      }

      final row = tile['row'];
      final col = tile['col'];
      if (row is! int ||
          col is! int ||
          row < 0 ||
          row > 14 ||
          col < 0 ||
          col > 14) {
        throw Exception('Invalid coordinates: row=$row, col=$col');
      }

      if (tile['points'] is! int || tile['points'] < 0) {
        throw Exception('Invalid points value');
      }
    }
  }
}
