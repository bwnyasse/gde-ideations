import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import '../services/firebase_service.dart';

class GeminiService {
  late GenerativeModel _model;
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  GeminiService() {
    _model =
        FirebaseVertexAI.instance.generativeModel(model: 'gemini-2.0-flash-exp');
  }

  Future<String> _uploadImageToStorage(
      String sessionId, String imagePath, int moveNumber) async {
    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Image file not found at $imagePath');
      }

      final fileName = 'moves/${sessionId}/${moveNumber}.jpg';
      final ref = _storage.ref().child(fileName);

      // Create upload task
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'sessionId': sessionId,
            'moveNumber': moveNumber.toString(),
          },
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print(
            'Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
      });

      // Wait for upload to complete
      await uploadTask;

      print('Image uploaded successfully to $fileName');
      return fileName;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<Map<String, dynamic>> analyzeBoardImage(
    String sessionId,
    String imagePath,
  ) async {
    try {
      // Get current move number based on existing moves
      final moveCount = await _firebaseService.getMoveCount(sessionId);
      final currentMoveNumber = moveCount + 1;

      // Get previous board state
      final boardState = await _firebaseService.getBoardState(sessionId).first;
      final isFirstMove = boardState.isEmpty;

      // Upload current image with sequential naming
      final currentImagePath = await _uploadImageToStorage(
        sessionId,
        imagePath,
        currentMoveNumber,
      );

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
        final previousImageRef =
            _storage.ref().child('moves/$sessionId/$previousMoveNumber.jpg');

        final prevImageBytes = await previousImageRef.getData();
        if (prevImageBytes == null) {
          throw Exception('Previous move image not found');
        }

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
