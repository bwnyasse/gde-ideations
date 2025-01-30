// lib/src/services/score_calculator.dart
import '../models/board_square.dart';

class ScoreCalculator {
  // French Scrabble letter points
  static const Map<String, int> letterPoints = {
    'A': 1, 'B': 3, 'C': 3, 'D': 2, 'E': 1,
    'F': 4, 'G': 2, 'H': 4, 'I': 1, 'J': 8,
    'K': 10, 'L': 1, 'M': 2, 'N': 1, 'O': 1,
    'P': 3, 'Q': 8, 'R': 1, 'S': 1, 'T': 1,
    'U': 1, 'V': 4, 'W': 10, 'X': 10, 'Y': 10,
    'Z': 10, '*': 0, // Blank tiles worth 0 points
  };

  static SquareType getSquareType(int row, int col) {
    // Center square
    if (row == 7 && col == 7) {
      return SquareType.doubleWord;
    }

    // Triple Word Score
    if ((row == 0 || row == 14) && (col == 0 || col == 7 || col == 14) ||
        (row == 7 && (col == 0 || col == 14))) {
      return SquareType.tripleWord;
    }

    // Double Word Score
    if (row == col || row + col == 14) {
      if (row >= 1 && row <= 5 || row >= 9 && row <= 13) {
        return SquareType.doubleWord;
      }
    }

    // Triple Letter Score
    if ((row == 1 || row == 13) && (col == 5 || col == 9) ||
        (row == 5 || row == 9) &&
            (col == 1 || col == 5 || col == 9 || col == 13)) {
      return SquareType.tripleLetter;
    }

    // Double Letter Score
    if ((row == 3 || row == 11) && (col == 0 || col == 7 || col == 14) ||
        (row == 6 || row == 8) && (col == 2 || col == 6 || col == 8 || col == 12) ||
        (row == 0 || row == 7 || col == 14) && (col == 3 || col == 11)) {
      return SquareType.doubleLetter;
    }

    return SquareType.normal;
  }

  static int calculateScore(List<Map<String, dynamic>> tiles, {bool isFirstMove = false}) {
    int wordScore = 0;
    int wordMultiplier = 1;
    bool usedCenter = false;

    // Calculate base score with letter multipliers
    for (var tile in tiles) {
      int letterScore = letterPoints[tile['letter']] ?? 0;
      final squareType = getSquareType(tile['row'], tile['col']);

      // Check if using center square
      if (tile['row'] == 7 && tile['col'] == 7) {
        usedCenter = true;
      }

      // Apply letter multipliers
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

      wordScore += letterScore;
    }

    // Apply word multiplier
    wordScore *= wordMultiplier;

    // First move must use center square and gets double word score
    if (isFirstMove && usedCenter) {
      wordScore *= 2;
    }

    // Add Scrabble bonus (50 points) if all 7 letters are used
    if (tiles.length == 7) {
      wordScore += 50;
    }

    return wordScore;
  }
}