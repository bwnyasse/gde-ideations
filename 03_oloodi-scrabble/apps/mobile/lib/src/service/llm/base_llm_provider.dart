import 'package:oloodi_scrabble_end_user_app/src/models/move.dart';

abstract class BaseLLMProvider {
  Future<String> generateMoveExplanation(String playerName, Move move, int currentScore);
  Future<void> initialize();
  Future<void> dispose();
  
  // Helper method to create consistent prompt across providers
  String createPrompt(String playerName, Move move, int currentScore) {
    return '''
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
  }
}