// lib/src/services/board_validator.dart
import '../models/board_square.dart';

class ValidationResult {
  final bool isValid;
  final String? error;
  final bool connectsToExisting;
  final List<String> formedWords;

  ValidationResult({
    required this.isValid,
    this.error,
    required this.connectsToExisting,
    this.formedWords = const [],
  });
}

class BoardValidator {
  static ValidationResult validateMove({
    required List<Map<String, dynamic>> newTiles,
    required List<List<BoardSquare>> currentBoard,
    required bool isFirstMove,
  }) {
    // Check if tiles are within board bounds
    for (var tile in newTiles) {
      if (tile['row'] < 0 ||
          tile['row'] >= 15 ||
          tile['col'] < 0 ||
          tile['col'] >= 15) {
        return ValidationResult(
          isValid: false,
          error: 'Word placement extends beyond board boundaries',
          connectsToExisting: false,
        );
      }
    }

    // Check if first move uses center square
    if (isFirstMove) {
      bool usesCenterSquare =
          newTiles.any((tile) => tile['row'] == 7 && tile['col'] == 7);
      if (!isFirstMove) {
        return ValidationResult(
          isValid: false,
          error: 'First move must use the center square',
          connectsToExisting: false,
        );
      }
    }

    // Check for tile conflicts and connections
    bool connectsToExisting = false;
    List<String> formedWords = [];

    for (var tile in newTiles) {
      final row = tile['row'] as int;
      final col = tile['col'] as int;

      // Check for conflicts with existing tiles
      if (currentBoard[row][col].tile != null) {
        if (currentBoard[row][col].tile!['letter'] != tile['letter']) {
          return ValidationResult(
            isValid: false,
            error: 'Conflict with existing tile at row $row, col $col',
            connectsToExisting: false,
          );
        }
      }

      // Check for adjacent tiles (if not first move)
      if (!isFirstMove) {
        final directions = [(-1, 0), (1, 0), (0, -1), (0, 1)];
        for (var (dRow, dCol) in directions) {
          final newRow = row + dRow;
          final newCol = col + dCol;

          if (newRow >= 0 && newRow < 15 && newCol >= 0 && newCol < 15) {
            if (currentBoard[newRow][newCol].tile != null) {
              connectsToExisting = true;
              // Could collect formed words here
              break;
            }
          }
        }
      }
    }

    // After first move, must connect to existing tiles
    if (!isFirstMove && !connectsToExisting) {
      return ValidationResult(
        isValid: false,
        error: 'New word must connect to existing tiles',
        connectsToExisting: false,
      );
    }

    return ValidationResult(
      isValid: true,
      connectsToExisting: connectsToExisting,
      formedWords: formedWords,
    );
  }
}
