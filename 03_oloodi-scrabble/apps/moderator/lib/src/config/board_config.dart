// lib/src/config/board_config.dart

import 'package:flutter/material.dart';
import '../models/board_square.dart';

class BoardConfig {
  // Board dimensions
  static const int boardSize = 15;
  static const int centerSquare = 7;

  // Premium square colors
  static const Map<SquareType, Color> squareColors = {
    SquareType.normal: Colors.white,
    SquareType.tripleWord: Color(0xFFFFCDD2),    // Light red
    SquareType.doubleWord: Color(0xFFF8BBD0),    // Light pink
    SquareType.tripleLetter: Color(0xFFBBDEFB),  // Light blue
    SquareType.doubleLetter: Color(0xFFE1F5FE),  // Lighter blue
    SquareType.center: Color(0xFFF8BBD0),        // Same as double word
  };

  // Premium square locations
  static final Map<String, SquareType> _premiumSquares = _initializePremiumSquares();

  static Map<String, SquareType> _initializePremiumSquares() {
    final Map<String, SquareType> squares = {};

    // Triple Word Score squares
    for (var pos in [
      [0, 0], [0, 7], [0, 14],
      [7, 0], [7, 14],
      [14, 0], [14, 7], [14, 14]
    ]) {
      squares['${pos[0]}-${pos[1]}'] = SquareType.tripleWord;
    }

    // Double Word Score squares
    for (var i = 1; i <= 5; i++) {
      squares['$i-$i'] = SquareType.doubleWord;           // Diagonal from top-left
      squares['$i-${14 - i}'] = SquareType.doubleWord;    // Diagonal from top-right
      squares['${14 - i}-$i'] = SquareType.doubleWord;    // Diagonal from bottom-left
      squares['${14 - i}-${14 - i}'] = SquareType.doubleWord; // Diagonal from bottom-right
    }

    // Triple Letter Score squares
    for (var pos in [
      [1, 5], [1, 9], [5, 1], [5, 5], [5, 9], [5, 13],
      [9, 1], [9, 5], [9, 9], [9, 13], [13, 5], [13, 9]
    ]) {
      squares['${pos[0]}-${pos[1]}'] = SquareType.tripleLetter;
    }

    // Double Letter Score squares
    for (var pos in [
      [3, 0], [3, 7], [3, 14],
      [6, 2], [6, 6], [6, 8], [6, 12],
      [7, 3], [7, 11],
      [8, 2], [8, 6], [8, 8], [8, 12],
      [11, 0], [11, 7], [11, 14]
    ]) {
      squares['${pos[0]}-${pos[1]}'] = SquareType.doubleLetter;
    }

    // Center square
    squares['$centerSquare-$centerSquare'] = SquareType.center;

    return squares;
  }

  // Get square type for a given position
  static SquareType getSquareType(int row, int col) {
    if (row < 0 || row >= boardSize || col < 0 || col >= boardSize) {
      throw RangeError('Board position out of bounds');
    }
    return _premiumSquares['$row-$col'] ?? SquareType.normal;
  }

  // Get color for a square type
  static Color getSquareColor(SquareType type) {
    return squareColors[type] ?? Colors.white;
  }

  // Get color for a position
  static Color getColorForPosition(int row, int col) {
    return getSquareColor(getSquareType(row, col));
  }

  // Helper method to check if position is center square
  static bool isCenterSquare(int row, int col) {
    return row == centerSquare && col == centerSquare;
  }

  // Get display text for premium squares
  static String getSquareLabel(SquareType type) {
    switch (type) {
      case SquareType.tripleWord:
        return 'TW';
      case SquareType.doubleWord:
        return 'DW';
      case SquareType.tripleLetter:
        return 'TL';
      case SquareType.doubleLetter:
        return 'DL';
      case SquareType.center:
        return '★';
      default:
        return '';
    }
  }
}