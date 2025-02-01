import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/move.dart';

class AIService {
  late GenerativeModel _model;

  AIService() {
    _model = FirebaseVertexAI.instance
        .generativeModel(model: 'gemini-2.0-flash-exp');
    // Initialize TTS with Google provider
    TtsGoogle.init(
      apiKey: const String.fromEnvironment('GOOGLE_CLOUD_API_KEY'),
      withLogs: true, // Set to false in production
    );
  }

  Future<String> generateMoveExplanation(
      String playerName, Move move, int currentScore) async {
    try {
      final prompt = '''
      Explain this Scrabble move played by $playerName in a concise and engaging way:
      - Word: ${move.word}
      - Score for this move: ${move.score} points
      - Tiles placed: ${move.tiles.map((t) => '${t.letter}(${t.points})').join(', ')}
      - Current total score after this move: $currentScore points
      
      Please explain:
      1. Like you were talking directly to the player
      2. Why this is a good move
      3. How the score was calculated
      4. Any strategic implications
      Keep it brief but informative in 2 sentences maximum.
      ''';

      final response = await _model.generateContent([
        Content.multi([
          TextPart(prompt),
        ]),
      ]);

      if (response.text == null) {
        throw Exception('Empty response from Gemini');
      }

      // Clean markdown from the response for display
      final cleanedText = _cleanMarkdownText(response.text!);
      return cleanedText;
    } catch (e) {
      throw Exception('Failed to generate move explanation: $e');
    }
  }

  String _cleanMarkdownText(String markdown) {
    // Remove headers
    var cleaned = markdown.replaceAll(RegExp(r'#{1,6}\s.*\n'), '');

    // Remove bold and italic markers
    cleaned = cleaned.replaceAll(RegExp(r'\*\*|__|\*|_'), '');

    // Remove code blocks and inline code
    cleaned = cleaned.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    cleaned = cleaned.replaceAll(RegExp(r'`[^`]*`'), '');

    // Remove bullet points and numbered lists
    cleaned = cleaned.replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');

    // Remove links
    cleaned = cleaned.replaceAll(RegExp(r'\[([^\]]*)\]\([^\)]*\)'), r'$1');

    // Remove horizontal rules
    cleaned = cleaned.replaceAll(RegExp(r'^\s*[-*_]{3,}\s*'), '');

    // Remove extra whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned.trim();
  }

  Future<List<int>> convertToSpeech(String text) async {
    // Get voices
    final voicesResponse = await TtsGoogle.getVoices();

    //Pick an English Voice
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

    //Get the audio bytes.
    return ttsResponse.audio.buffer.asUint8List().toList();
  }
}
