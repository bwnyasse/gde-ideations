import 'package:flutter/material.dart';
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

// Add this method to MockGameService
SquareType getBoardSquareType(int row, int col) {
  // Center square
  if (row == 7 && col == 7) {
    return SquareType.center;
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

// Optional: Helper method to get a description of the square
String getSquareDescription(SquareType type) {
  switch (type) {
    case SquareType.normal:
      return '';
    case SquareType.doubleLetter:
      return 'DL';
    case SquareType.tripleLetter:
      return 'TL';
    case SquareType.doubleWord:
      return 'DW';
    case SquareType.tripleWord:
      return 'TW';
    case SquareType.center:
      return '★';
  }
}

// Optional: Helper method to get square color
Color getSquareColor(SquareType type) {
  switch (type) {
    case SquareType.normal:
      return Colors.white;
    case SquareType.doubleLetter:
      return Colors.lightBlue[50]!; // Light blue
    case SquareType.tripleLetter:
      return Colors.blue[100]!; // Dark blue
    case SquareType.doubleWord:
      return Colors.pink[50]!; // Pink
    case SquareType.tripleWord:
      return Colors.red[100]!; // Red
    case SquareType.center:
      return Colors.pink[50]!; // Same as DW
  }
}
