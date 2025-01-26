import 'package:flutter/material.dart';
import '../models/board_square.dart';
import '../models/move.dart';
import '../models/tile.dart';
import '../models/player.dart';

class GameStateProvider with ChangeNotifier {
  List<List<BoardSquare>> _board = [];
  List<Move> _moves = [];
  String _currentPlayerId = 'p1';  // Track current player

  // Define players
  final List<Player> players = [
    Player(id: 'p1', name: 'Player 1', color: Colors.blue[300]!),
    Player(id: 'p2', name: 'Player 2', color: Colors.green[300]!),
  ];

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
    final sampleMoves = [
      Move(
        word: "HELLO",
        score: 8,
        playerId: 'p1',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        tiles: [
          PlacedTile(letter: "H", row: 7, col: 7, points: 4),
          PlacedTile(letter: "E", row: 7, col: 8, points: 1),
          PlacedTile(letter: "L", row: 7, col: 9, points: 1),
          PlacedTile(letter: "L", row: 7, col: 10, points: 1),
          PlacedTile(letter: "O", row: 7, col: 11, points: 1),
        ],
      ),
      Move(
        word: "WORLD",
        score: 12,
        playerId: 'p2',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        tiles: [
          PlacedTile(letter: "W", row: 7, col: 11, points: 4),
          PlacedTile(letter: "O", row: 8, col: 11, points: 1),
          PlacedTile(letter: "R", row: 9, col: 11, points: 1),
          PlacedTile(letter: "L", row: 10, col: 11, points: 1),
          PlacedTile(letter: "D", row: 11, col: 11, points: 2),
        ],
      ),
    ];

    for (var move in sampleMoves) {
      addMove(move);
    }
  }

  void addMove(Move move) {
    _moves.add(move);
    for (var tile in move.tiles) {
      _board[tile.row][tile.col].tile = Tile(
        letter: tile.letter,
        points: tile.points,
        playerId: move.playerId,
        isNew: true,
      );
    }
    // Switch current player
    _currentPlayerId = _currentPlayerId == 'p1' ? 'p2' : 'p1';
    notifyListeners();
    
    // Reset the "new" flag after animation
    Future.delayed(const Duration(milliseconds: 800), () {
      for (var tile in move.tiles) {
        if (_board[tile.row][tile.col].tile != null) {
          _board[tile.row][tile.col].tile!.isNew = false;
        }
      }
      notifyListeners();
    });
  }

  void simulateNewMove() {
    final move = Move(
      word: "QUIZ",
      score: 22,
      playerId: _currentPlayerId,
      timestamp: DateTime.now(),
      tiles: [
        PlacedTile(letter: "Q", row: 5, col: 5, points: 10),
        PlacedTile(letter: "U", row: 5, col: 6, points: 1),
        PlacedTile(letter: "I", row: 5, col: 7, points: 1),
        PlacedTile(letter: "Z", row: 5, col: 8, points: 10),
      ],
    );
    
    addMove(move);
  }

  List<Move> getMovesByPlayer(String playerId) {
    return _moves.where((move) => move.playerId == playerId).toList();
  }

  int getPlayerScore(String playerId) {
    return _moves
        .where((move) => move.playerId == playerId)
        .fold(0, (sum, move) => sum + move.score);
  }

  // Getters
  List<List<BoardSquare>> get board => _board;
  List<Move> get moves => _moves;
  String get currentPlayerId => _currentPlayerId;
  
  Player getCurrentPlayer() {
    return players.firstWhere((player) => player.id == _currentPlayerId);
  }

  bool isCurrentPlayer(String playerId) {
    return playerId == _currentPlayerId;
  }
}