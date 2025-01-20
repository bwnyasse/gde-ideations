import 'package:flutter/foundation.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/board.dart';

class GameStateProvider with ChangeNotifier {
  Board _board = Board();
  List<String> _moveHistory = [];
  int _currentScore = 0;
  
  Board get board => _board;
  List<String> get moveHistory => List.unmodifiable(_moveHistory);
  int get currentScore => _currentScore;
  
  void updateBoard(Board newBoard) {
    _board = newBoard;
    notifyListeners();
  }
  
  void addMove(String move, int score) {
    _moveHistory.add(move);
    _currentScore += score;
    notifyListeners();
  }
}