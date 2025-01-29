import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/env_config.dart';
import '../services/firebase_service.dart';

class GeminiService {
  late GenerativeModel _model;
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: 'AIzaSyAMRHzq6_i_jVDUfxOooscv5riCNIxqyXQ',
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
    );
  }

  Future<String> _uploadImageToStorage(
      String sessionId, String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Image file not found at $imagePath');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'moves/${sessionId}_$timestamp.jpg';
      final ref = _storage.ref().child(fileName);

      // Create upload task
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'sessionId': sessionId,
            'timestamp': timestamp.toString(),
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

      // Get download URL (optional, if you need it)
      final downloadUrl = await ref.getDownloadURL();
      print('Image uploaded successfully. Download URL: $downloadUrl');

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
      // Get previous board state and last image
      final boardState = await _firebaseService.getBoardState(sessionId).first;
      final isFirstMove = boardState.isEmpty;

      // Upload current image to Firebase Storage
      final currentImagePath =
          await _uploadImageToStorage(sessionId, imagePath);

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
        };
      } else {
        // Get previous image
        final lastMove = await _firebaseService.getLastMove(sessionId);
        if (lastMove == null || lastMove.imagePath == null) {
          throw Exception('Previous move image not found');
        }

        // Download previous image
        final prevImageRef = _storage.ref().child(lastMove.imagePath!);
        final prevImageBytes = await prevImageRef.getData();

        if (prevImageBytes == null) {
          throw Exception('Failed to download previous image');
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
You are analyzing an initial Scrabble board image. Identify all visible letters and their positions.

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
Compare these two Scrabble board images: the first is the previous state, the second is the current state.
Identify ONLY the letters that appear in the second image but not in the first.

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
- Compare the images to find ONLY new letters
- Calculate score including board multipliers
- Return ONLY the JSON, no explanatory text
- Use 0-based indices (0-14) for coordinates
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
