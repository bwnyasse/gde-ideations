// lib/services/mock_game_service.dart
import 'dart:math';

import 'package:oloodi_scrabble_end_user_app/src/models/board_square.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/move.dart';

class MockGameService {
  // Official French Scrabble distribution (102 tiles including 2 blank/joker)
  static final Map<String, int> _initialLetterBag = {
    'A': 9, 'B': 2, 'C': 2, 'D': 3, 'E': 15,
    'F': 2, 'G': 2, 'H': 2, 'I': 8, 'J': 1,
    'K': 1, 'L': 5, 'M': 3, 'N': 6, 'O': 6,
    'P': 2, 'Q': 1, 'R': 6, 'S': 6, 'T': 6,
    'U': 6, 'V': 2, 'W': 1, 'X': 1, 'Y': 1,
    'Z': 1, '*': 2, // '*' represents blank/joker tiles
  };

  // Official French Scrabble points
  static final Map<String, int> letterPoints = {
    'A': 1, 'B': 3, 'C': 3, 'D': 2, 'E': 1,
    'F': 4, 'G': 2, 'H': 4, 'I': 1, 'J': 8,
    'K': 10, 'L': 1, 'M': 2, 'N': 1, 'O': 1,
    'P': 3, 'Q': 8, 'R': 1, 'S': 1, 'T': 1,
    'U': 1, 'V': 4, 'W': 10, 'X': 10, 'Y': 10,
    'Z': 10, '*': 0, // Blanks worth 0 points
  };

  static Map<String, int> _remainingLetters = Map.from(_initialLetterBag);
  static List<List<String?>> _boardState =
      List.generate(15, (_) => List.generate(15, (_) => null));
  static int _consecutivePasses = 0;

  static void resetGame() {
    _remainingLetters = Map.from(_initialLetterBag);
    _boardState = List.generate(15, (_) => List.generate(15, (_) => null));
    _consecutivePasses = 0;
  }

  static int getRemainingLettersCount() {
    return _remainingLetters.values.fold(0, (sum, count) => sum + count);
  }

  static bool isGameOver() {
    // Game ends if:
    // 1. No more letters in bag and a player has used all their letters
    // 2. Three consecutive passes by all players
    // 3. No more valid moves possible and insufficient letters to exchange
    return getRemainingLettersCount() == 0 || _consecutivePasses >= 3;
  }

  static bool _isValidWordPlacement(
      String word, int row, int col, bool isHorizontal, bool isFirstMove) {
    // First move must cross center square
    if (isFirstMove) {
      bool crossesCenter = false;
      for (int i = 0; i < word.length; i++) {
        final currentRow = isHorizontal ? row : row + i;
        final currentCol = isHorizontal ? col + i : col;
        if (currentRow == 7 && currentCol == 7) {
          crossesCenter = true;
          break;
        }
      }
      if (!crossesCenter) return false;
    }

    // Check board boundaries
    if (isHorizontal) {
      if (col + word.length > 15) return false;
    } else {
      if (row + word.length > 15) return false;
    }

    bool connectsToExisting = false;

    // Check each position
    for (int i = 0; i < word.length; i++) {
      final currentRow = isHorizontal ? row : row + i;
      final currentCol = isHorizontal ? col + i : col;

      // Check if current position has a letter
      if (_boardState[currentRow][currentCol] != null) {
        if (_boardState[currentRow][currentCol] != word[i]) {
          return false; // Conflict with existing letter
        }
        connectsToExisting = true;
      }

      // Check adjacent positions
      if (!isFirstMove) {
        if (_hasAdjacentTiles(currentRow, currentCol)) {
          connectsToExisting = true;
        }
      }
    }

    return isFirstMove || connectsToExisting;
  }

  static bool _hasAdjacentTiles(int row, int col) {
    final directions = [(-1, 0), (1, 0), (0, -1), (0, 1)];

    for (var (dRow, dCol) in directions) {
      final newRow = row + dRow;
      final newCol = col + dCol;

      if (newRow >= 0 && newRow < 15 && newCol >= 0 && newCol < 15) {
        if (_boardState[newRow][newCol] != null) {
          return true;
        }
      }
    }

    return false;
  }

  static List<String> _getAvailableLetters() {
    List<String> available = [];
    _remainingLetters.forEach((letter, count) {
      for (int i = 0; i < count; i++) {
        available.add(letter);
      }
    });
    return available;
  }

  static void _removeLettersFromBag(String word) {
    for (var letter in word.split('')) {
      if (_remainingLetters.containsKey(letter) &&
          _remainingLetters[letter]! > 0) {
        _remainingLetters[letter] = _remainingLetters[letter]! - 1;
      }
    }
  }

  static List<Move> generateSampleMoves() {
    resetGame();
    final moves = <Move>[];

    // Start with a valid first move
    final random = Random();
    final firstMoveIndex = random.nextInt(_validFirstMoves.length);
    final (word, tiles) = _validFirstMoves[firstMoveIndex];

    final firstMove = Move(
      word: word,
      score: calculateWordScore(tiles, true),
      playerId: 'p1',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      tiles: tiles,
    );

    moves.add(firstMove);
    _updateBoardState(firstMove);
    _removeLettersFromBag(word);

    return moves;
  }

  static void _updateBoardState(Move move) {
    for (var tile in move.tiles) {
      _boardState[tile.row][tile.col] = tile.letter;
    }
  }

  // Sample valid French words for simulation
  static final List<String> _validWords = [
    "CADEAU",
    "TABLEAU",
    "MAISON",
    "JARDIN",
    "VOITURE",
    "ÉCOLE",
    "RAPIDE",
    "CHEVAL",
    "MUSIQUE",
    "FLEUR",
    "SOLEIL",
    "PORTE",
    "TABLE",
    "LIVRE",
    "ARBRE",
    "CHAT",
    "CHIEN",
    "OISEAU",
    "POISSON",
    "FRUIT"
  ];

  static Move? simulateNextMove(String currentPlayerId) {
    if (isGameOver()) return null;

    // If this is the first move, use one of our predefined first moves
    if (_isBoardEmpty()) {
      final firstMove = generateSampleMoves().first;
      return Move(
        word: firstMove.word,
        score: firstMove.score,
        playerId: currentPlayerId,
        timestamp: DateTime.now(),
        tiles: firstMove.tiles,
      );
    }

    // Try to find a valid move using available letters
    for (String word in _validWords) {
      if (_canMakeWord(word)) {
        // Try horizontal placement
        for (int row = 0; row < 15; row++) {
          for (int col = 0; col < 15; col++) {
            if (_isValidWordPlacement(word, row, col, true, false)) {
              final tiles = _createTilesForWord(word, row, col, true);
              final score = calculateWordScore(tiles, false);

              _removeLettersFromBag(word);
              _consecutivePasses = 0;

              return Move(
                word: word,
                score: score,
                playerId: currentPlayerId,
                timestamp: DateTime.now(),
                tiles: tiles,
              );
            }
          }
        }

        // Try vertical placement
        for (int col = 0; col < 15; col++) {
          for (int row = 0; row < 15; row++) {
            if (_isValidWordPlacement(word, row, col, false, false)) {
              final tiles = _createTilesForWord(word, row, col, false);
              final score = calculateWordScore(tiles, false);

              _removeLettersFromBag(word);
              _consecutivePasses = 0;

              return Move(
                word: word,
                score: score,
                playerId: currentPlayerId,
                timestamp: DateTime.now(),
                tiles: tiles,
              );
            }
          }
        }
      }
    }

    // If no valid move found, increment passes
    _consecutivePasses++;
    return null;
  }

  static bool _canMakeWord(String word) {
    Map<String, int> availableLetters = Map.from(_remainingLetters);

    for (String letter in word.split('')) {
      if (!availableLetters.containsKey(letter) ||
          availableLetters[letter]! <= 0) {
        return false;
      }
      availableLetters[letter] = availableLetters[letter]! - 1;
    }

    return true;
  }

  static bool _isBoardEmpty() {
    for (var row in _boardState) {
      for (var cell in row) {
        if (cell != null) return false;
      }
    }
    return true;
  }

  static List<PlacedTile> _createTilesForWord(
      String word, int startRow, int startCol, bool isHorizontal) {
    List<PlacedTile> tiles = [];

    for (int i = 0; i < word.length; i++) {
      final letter = word[i];
      final row = isHorizontal ? startRow : startRow + i;
      final col = isHorizontal ? startCol + i : startCol;

      // Only create tiles for new letters (not existing ones on board)
      if (_boardState[row][col] == null) {
        tiles.add(PlacedTile(
          letter: letter,
          row: row,
          col: col,
          points: letterPoints[letter] ?? 0,
        ));
      }
    }

    return tiles;
  }

  static SquareType getBoardSquareType(int row, int col) {
    // Center square - acts as Double Word Score
    if (row == 7 && col == 7) {
      return SquareType.doubleWord; // Changed from center to doubleWord
    }

    // Triple Word Score (Red)
    if ((row == 0 || row == 14) &&
            (col == 0 || col == 7 || col == 14) || // Corners and middle edges
        (row == 7 && (col == 0 || col == 14))) {
      // Middle row edges
      return SquareType.tripleWord;
    }

    // Double Word Score (Pink)
    if (row == col || row + col == 14) {
      // Diagonals
      if (row >= 1 && row <= 5 || row >= 9 && row <= 13) {
        // Excluding center and edges
        return SquareType.doubleWord;
      }
    }

    // Triple Letter Score (Dark Blue)
    if ((row == 1 || row == 13) && (col == 5 || col == 9) || // Near top/bottom
        (row == 5 || row == 9) &&
            (col == 1 || col == 5 || col == 9 || col == 13)) {
      // Middle area
      return SquareType.tripleLetter;
    }

    // Double Letter Score (Light Blue)
    if ((row == 3 || row == 11) &&
            (col == 0 || col == 7 || col == 14) || // Top/bottom edges
        (row == 6 || row == 8) &&
            (col == 2 || col == 6 || col == 8 || col == 12) || // Middle area
        (row == 0 || row == 7 || row == 14) &&
            (col == 3 || col == 11) || // Left/right edges
        (row == 2 || row == 12) && (col == 6 || col == 8)) {
      // Additional DL squares
      return SquareType.doubleLetter;
    }

    // Normal square
    return SquareType.normal;
  }

// Update calculateWordScore to explicitly check for center square in first move
  static int calculateWordScore(List<PlacedTile> tiles, bool isFirstMove) {
    int wordMultiplier = 1;
    int wordScore = 0;
    bool usedCenterSquare = false;

    for (var tile in tiles) {
      int letterScore = letterPoints[tile.letter] ?? 0;

      // Check if this tile uses the center square
      if (tile.row == 7 && tile.col == 7) {
        usedCenterSquare = true;
      }

      // Apply letter multipliers based on board position
      switch (getBoardSquareType(tile.row, tile.col)) {
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

    // First move must cross center square and gets double word score
    if (isFirstMove && usedCenterSquare) {
      wordScore *=
          2; // Ensure center square doubles the word score for first move
    }

    // Add Scrabble bonus (50 points) if all 7 letters are used
    if (tiles.length == 7) {
      wordScore += 50;
    }

    return wordScore;
  }

// Update the first move generation to ensure it uses the center square
  static final List<(String, List<PlacedTile>)> _validFirstMoves = [
    (
      "ÉTOILE",
      [
        PlacedTile(letter: "É", row: 7, col: 5, points: 1),
        PlacedTile(letter: "T", row: 7, col: 6, points: 1),
        PlacedTile(
            letter: "O", row: 7, col: 7, points: 1), // Center square - DW
        PlacedTile(letter: "I", row: 7, col: 8, points: 1),
        PlacedTile(letter: "L", row: 7, col: 9, points: 1),
        PlacedTile(letter: "E", row: 7, col: 10, points: 1),
      ]
    ),
    // Add more valid French first words that cross center
  ];
}
