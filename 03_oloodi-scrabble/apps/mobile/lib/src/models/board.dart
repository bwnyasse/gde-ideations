import 'package:oloodi_scrabble_end_user_app/src/models/tile.dart';

class Board {
  static const int boardSize = 15;
  final List<List<Tile?>> tiles;
  
  Board() : tiles = List.generate(
    boardSize,
    (_) => List.generate(boardSize, (_) => null)
  );
  
  bool isValidPlacement(int row, int col) {
    if (row < 0 || row >= boardSize || col < 0 || col >= boardSize) {
      return false;
    }
    return tiles[row][col] == null;
  }
  
  // Additional board logic will go here
}