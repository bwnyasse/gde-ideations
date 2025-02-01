import 'package:oloodi_scrabble_end_user_app/src/models/tile.dart';

class BoardSquare {
  final int row;
  final int col;
  final SquareType type;
  Tile? tile;

  BoardSquare({
    required this.row,
    required this.col,
    required this.type,
    this.tile,
  });
}

// Add this to your models/board_square.dart or where your SquareType enum is defined
enum SquareType {
  normal,
  doubleLetter, // Light blue - DL
  tripleLetter, // Dark blue - TL
  doubleWord, // Pink - DW
  tripleWord, // Red - TW
  center // Center square (acts as DW)
}

  // Get square type for board initialization
  SquareType getSquareType(int row, int col) {
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
        (row == 6 || row == 8) &&
            (col == 2 || col == 6 || col == 8 || col == 12) ||
        (row == 0 || row == 7 || col == 14) && (col == 3 || col == 11)) {
      return SquareType.doubleLetter;
    }

    return SquareType.normal;
  }