import 'package:flutter/foundation.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/board_square.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/move.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/tile.dart';
import 'package:oloodi_scrabble_end_user_app/src/service/mock_game_service.dart';
class GameStateProvider with ChangeNotifier {
  List<List<BoardSquare>> _board = [];
  List<Move> _moves = [];
  int _currentPlayerScore = 0;
  int _opponentScore = 0;
  
  GameStateProvider() {
    _initializeBoard();
    _loadSampleMoves();
  }

  void _initializeBoard() {
    _board = List.generate(15, (row) {
      return List.generate(15, (col) {
        return BoardSquare(
          row: row,
          col: col,
          type: _getSquareType(row, col),
        );
      });
    });
  }

  SquareType _getSquareType(int row, int col) {
    // Center square
    if (row == 7 && col == 7) return SquareType.center;

    // Triple Word Score
    if ((row == 0 || row == 14) && (col == 0 || col == 7 || col == 14) ||
        (row == 7 && (col == 0 || col == 14))) {
      return SquareType.tripleWord;
    }

    // Double Word Score
    if (row == col || row + col == 14) {
      if (row >= 1 && row <= 4 || row >= 10 && row <= 13) {
        return SquareType.doubleWord;
      }
    }

    // Triple Letter Score
    if ((row == 1 || row == 13) && (col == 5 || col == 9) ||
        (row == 5 || row == 9) && (col == 1 || col == 5 || col == 9 || col == 13)) {
      return SquareType.tripleLetter;
    }

    // Double Letter Score
    if ((row == 3 || row == 11) && (col == 0 || col == 7 || col == 14) ||
        (row == 6 || row == 8) && (col == 2 || col == 6 || col == 8 || col == 12) ||
        (row == 0 || row == 7 || row == 14) && (col == 3 || col == 11)) {
      return SquareType.doubleLetter;
    }

    return SquareType.normal;
  }

  void _loadSampleMoves() {
    _moves = MockGameService.generateSampleMoves();
    for (var move in _moves) {
      _applyMove(move);
    }
    notifyListeners();
  }

  void _applyMove(Move move) {
    for (var tile in move.tiles) {
      _board[tile.row][tile.col].tile = Tile(
        letter: tile.letter,
        points: tile.points,
      );
    }
    if (move.playedBy == "Player 1") {
      _currentPlayerScore += move.score;
    } else {
      _opponentScore += move.score;
    }
  }

  void simulateNewMove() {
    final move = Move(
      word: "QUIZ",
      score: 22,
      playedBy: "Player 1",
      timestamp: DateTime.now(),
      tiles: [
        PlacedTile(letter: "Q", row: 5, col: 5, points: 10),
        PlacedTile(letter: "U", row: 5, col: 6, points: 1),
        PlacedTile(letter: "I", row: 5, col: 7, points: 1),
        PlacedTile(letter: "Z", row: 5, col: 8, points: 10),
      ],
    );
    
    _moves.add(move);
    _applyMove(move);
    notifyListeners();
  }

  List<List<BoardSquare>> get board => _board;
  List<Move> get moves => _moves;
  int get currentPlayerScore => _currentPlayerScore;
  int get opponentScore => _opponentScore;
}
