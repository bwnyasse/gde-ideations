import 'package:oloodi_scrabble_end_user_app/src/models/move.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/settings_provider.dart';

abstract class BaseLLMProvider {
  Future<String> generateMoveExplanation(
      String playerName, Move move, int currentScore, AppLanguage language);
  Future<void> initialize();
  Future<void> dispose();

  String createPrompt(
      String playerName, Move move, int currentScore, AppLanguage language) {
    final isEnglish = language == AppLanguage.english;

    return '''
    ${isEnglish ? 'Explain' : 'Explique'} ${isEnglish ? 'this Scrabble move played by' : 'ce coup de Scrabble joué par'} $playerName ${isEnglish ? 'in a concise and engaging way' : 'de manière concise et engageante'}:
    - ${isEnglish ? 'Word' : 'Mot'}: ${move.word}
    - ${isEnglish ? 'Score for this move' : 'Score pour ce coup'}: ${move.score} ${isEnglish ? 'points' : 'points'}
    - ${isEnglish ? 'Tiles placed' : 'Lettres placées'}: ${move.tiles.map((t) => '${t.letter}(${t.points})').join(', ')}
    - ${isEnglish ? 'Current total score after this move' : 'Score total actuel après ce coup'}: $currentScore ${isEnglish ? 'points' : 'points'}
    
    ${isEnglish ? 'Please explain' : 'Veuillez expliquer'}:
    1. ${isEnglish ? 'Like you were talking directly to the player' : 'Comme si vous parliez directement au joueur'}
    2. ${isEnglish ? 'Why this is a good move' : 'Pourquoi c\'est un bon coup'}
    3. ${isEnglish ? 'How the score was calculated' : 'Comment le score a été calculé'}
    4. ${isEnglish ? 'Any strategic implications' : 'Les implications stratégiques'}
    ${isEnglish ? 'Keep it brief but informative in 2 sentences maximum.' : 'Gardez cela bref mais informatif en 2 phrases maximum.'}
    ${isEnglish ? 'Please respond in English.' : 'Veuillez répondre en français.'}
    ''';
  }
}
