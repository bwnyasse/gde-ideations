// lib/src/services/score_calculator.dart

import '../config/board_config.dart';
import '../models/board_square.dart';

class ScoreCalculator {
  // French Scrabble letter points
  static const Map<String, int> letterPoints = {
    'A': 1, 'B': 3, 'C': 3, 'D': 2, 'E': 1,
    'F': 4, 'G': 2, 'H': 4, 'I': 1, 'J': 8,
    'K': 10, 'L': 1, 'M': 2, 'N': 1, 'O': 1,
    'P': 3, 'Q': 8, 'R': 1, 'S': 1, 'T': 1,
    'U': 1, 'V': 4, 'W': 10, 'X': 10, 'Y': 10,
    'Z': 10, '*': 0  // Blank tiles
  };

  static int calculateScore(List<Map<String, dynamic>> tiles, {bool isFirstMove = false}) {
    int baseScore = 0;
    int wordMultiplier = 1;
    bool usesCenterSquare = false;

    // First pass: Calculate base scores and collect multipliers
    for (var tile in tiles) {
      final row = tile['row'] as int;
      final col = tile['col'] as int;
      final letter = tile['letter'] as String;
      final squareType = BoardConfig.getSquareType(row, col);
      
      // Track center square usage
      if (BoardConfig.isCenterSquare(row, col)) {
        usesCenterSquare = true;
      }

      // Get base letter score
      int letterScore = letterPoints[letter] ?? 0;

      // Handle letter multipliers immediately
      switch (squareType) {
        case SquareType.doubleLetter:
          letterScore *= 2;
          break;
        case SquareType.tripleLetter:
          letterScore *= 3;
          break;
        case SquareType.doubleWord:
          wordMultiplier *= 2;
          break;
        case SquareType.tripleWord:
          wordMultiplier *= 3;
          break;
        default:
          break;
      }

      baseScore += letterScore;
    }

    // Apply word multiplier to total base score
    int finalScore = baseScore * wordMultiplier;

    // First move validation and bonus
    if (isFirstMove) {
      if (!usesCenterSquare) return 0; // Invalid move
    }

    // Add bingo bonus (50 points) for using all 7 tiles
    if (tiles.length == 7) {
      finalScore += 50;
    }

    return finalScore;
  }
}