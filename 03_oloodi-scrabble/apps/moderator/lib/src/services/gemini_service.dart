import 'dart:convert';
import 'dart:io';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:oloodi_scrabble_moderator_app/src/services/image_storage_service.dart';
import '../services/firebase_service.dart';

class GeminiService {
  late GenerativeModel _model;
  final ImageStorageService _imageStorage = ImageStorageService();
  final FirebaseService _firebaseService = FirebaseService();

  GeminiService() {
    _model = FirebaseVertexAI.instance
        .generativeModel(model: 'gemini-2.0-flash-exp');
  }

  Future<Map<String, dynamic>> analyzeBoardImage(
    String sessionId,
    String imagePath,
  ) async {
    try {
      // Get current move number based on existing moves
      final moveCount = await _firebaseService.getMoveCount(sessionId);
      final currentMoveNumber = moveCount + 1;

      // Upload image using the new ImageStorageService
      final currentImagePath = await _imageStorage.uploadMoveImage(
        sessionId: sessionId,
        imagePath: imagePath,
        moveNumber: currentMoveNumber,
        onProgress: (progress) {
          print('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
        },
      );

      // Get previous board state
      final boardState = await _firebaseService.getBoardState(sessionId).first;
      final isFirstMove = boardState.isEmpty;

      // Read current image bytes
      final currentImageBytes = await File(imagePath).readAsBytes();

      if (isFirstMove) {
        // Handle first move
        final response = await _model.generateContent([
          Content.multi([
            TextPart(_constructInitialBoardPrompt()),
            DataPart('image/jpeg', currentImageBytes),
          ]),
        ]);

        if (response.text == null) {
          throw Exception('Empty response from Gemini');
        }

        return {
          'status': 'success',
          'type': 'initial',
          'data': _parseGeminiResponse(response.text!, true),
          'imagePath': currentImagePath,
          'moveNumber': currentMoveNumber,
        };
      } else {
        // Get previous image
        final previousMoveNumber = currentMoveNumber - 1;
        final previousImagePath = await _imageStorage.downloadImage(
          'moves/$sessionId/move_$previousMoveNumber.jpg',
          // Provide a temporary local path for the downloaded file
          '${Directory.systemTemp.path}/prev_move_$previousMoveNumber.jpg',
        );

        final prevImageBytes = await previousImagePath.readAsBytes();

        // Compare images using Gemini
        final response = await _model.generateContent([
          Content.multi([
            TextPart(_constructImageComparisonPrompt(boardState)),
            DataPart('image/jpeg', prevImageBytes),
            DataPart('image/jpeg', currentImageBytes),
          ]),
        ]);

        if (response.text == null) {
          throw Exception('Empty response from Gemini');
        }

        return {
          'status': 'success',
          'type': 'move',
          'data': _parseGeminiResponse(response.text!, false),
          'imagePath': currentImagePath,
          'moveNumber': currentMoveNumber,
        };
      }
    } catch (e) {
      print('Error in analyzeBoardImage: $e');
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  String _constructInitialBoardPrompt() {
    return '''
You are analyzing an image of an initial Scrabble board move. The image is clear and well-lit. 
Accurately identify all visible letters and their precise positions on the board, using the center star 
as a reference point. It is crucial that the letter positions are identified correctly.
Determine the word played and its score, including any applicable board multipliers.

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

Rules:

- Use 0-based indices (0-14) for rows and columns
- Include ONLY placed letters, ignore empty squares
- All coordinates must be within the 15x15 grid
- Return ONLY the JSON, no explanatory text
''';
  }

  String _constructImageComparisonPrompt(Map<String, dynamic> previousState) {
    return '''
Compare these two Scrabble board images: the first is the previous state before a move, the second is the current state after a move.
Identify ONLY the letters that appear in the second image but not in the first.

Determine the word played and its score, including any applicable board multipliers.

Previous board state for reference:
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

Rules:
- Calculate score including board multipliers
- Calculate the score based on the tile values and any board multipliers active during the play. Do not include the 50-point bonus for using all 7 tiles.
- Return ONLY the JSON, no explanatory text
- Use 0-based indices (0-14) for coordinates
- All coordinates must be within the 15x15 grid
- If no valid word was played (e.g., the board states are identical), return: {"word": "", "score": 0, "newLetters": []}
''';
  }

  Map<String, dynamic> _parseGeminiResponse(String response, bool isFirstMove) {
    try {
      String cleanJson = response
          .replaceAll(RegExp(r'```json\n?'), '')
          .replaceAll(RegExp(r'```\n?'), '')
          .trim();

      return jsonDecode(cleanJson);
    } catch (e) {
      throw Exception('Invalid response format: $e');
    }
  }
}
