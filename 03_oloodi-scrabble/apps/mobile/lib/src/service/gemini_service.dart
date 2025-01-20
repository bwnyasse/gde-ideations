import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

class GeminiService {
  static const String _apiKey =
      'YOUR_API_KEY_HERE'; // Replace with actual API key
  late GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: _apiKey,
    );
  }

  Future<Map<String, dynamic>> analyzeBoardImage(String imagePath) async {
    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final prompt = '''
        Analyze this Scrabble board image and provide:
        1. All visible words on the board
        2. Position of each word (row and column coordinates)
        3. Score for each word based on letter values and multipliers
        Format the response as JSON with the following structure:
        {
          "words": [
            {
              "word": "string",
              "start": {"row": int, "col": int},
              "direction": "horizontal|vertical",
              "score": int
            }
          ]
        }
      ''';

      final response = await _model.generateContent([
        Content.text(prompt),
        // Content.image(imageBytes),
      ]);

      final jsonResponse = response.text;
      // Parse and validate JSON response
      // Implementation needed

      return {'status': 'success', 'data': jsonResponse};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<String> explainMove(String word, List<String> definitions) async {
    try {
      final prompt = '''
        Explain the Scrabble move for the word "$word":
        1. Word meaning and usage
        2. Strategic value in Scrabble
        3. Alternative words possible with same letters
      ''';

      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      return response.text ?? '';
    } catch (e) {
      return 'Failed to generate move explanation: ${e.toString()}';
    }
  }
}
