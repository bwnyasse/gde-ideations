// lib/src/models/board_square.dart
enum SquareType {
  normal,
  doubleLetter,
  tripleLetter,
  doubleWord,
  tripleWord,
  center
}

class BoardSquare {
  final int row;
  final int col;
  final SquareType type;
  Map<String, dynamic>? tile;

  BoardSquare({
    required this.row,
    required this.col,
    required this.type,
    this.tile,
  });

  // Convert from string type (used in Firebase) to SquareType
  static SquareType typeFromString(String type) {
    switch (type) {
      case 'tripleWord':
        return SquareType.tripleWord;
      case 'doubleWord':
        return SquareType.doubleWord;
      case 'tripleLetter':
        return SquareType.tripleLetter;
      case 'doubleLetter':
        return SquareType.doubleLetter;
      case 'center':
        return SquareType.center;
      default:
        return SquareType.normal;
    }
  }

  // Convert from SquareType to string (for Firebase)
  static String typeToString(SquareType type) {
    switch (type) {
      case SquareType.tripleWord:
        return 'tripleWord';
      case SquareType.doubleWord:
        return 'doubleWord';
      case SquareType.tripleLetter:
        return 'tripleLetter';
      case SquareType.doubleLetter:
        return 'doubleLetter';
      case SquareType.center:
        return 'center';
      default:
        return 'normal';
    }
  }
}