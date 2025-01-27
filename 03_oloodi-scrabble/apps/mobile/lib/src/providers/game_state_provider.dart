import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/service/mock_game_service.dart';
import '../models/board_square.dart';
import '../models/move.dart';
import '../models/tile.dart';
import '../models/player.dart';

class GameStateProvider with ChangeNotifier {
  // Board state
  List<List<BoardSquare>> _board = [];
  List<Move> _moves = [];
  String _currentPlayerId = 'p1';
  bool _isGameOver = false;

  // Players
  final List<Player> players = [
    Player(
      id: 'p1',
      name: 'Player 1',
      color: Colors.blue[300]!,
      imagePath: 'images/player_1.png',
    ),
    Player(
      id: 'p2',
      name: 'Player 2',
      color: Colors.green[300]!,
      imagePath: 'images/player_2.png',
    ),
  ];

  // Constructor
  GameStateProvider() {
    _initializeBoard();
    _initializeGame();
  }

  // Initialize the game board
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

  // Initialize game state
  void _initializeGame() {
    _moves.clear();
    _currentPlayerId = 'p1';
    _isGameOver = false;

    final sampleMoves = MockGameService.generateSampleMoves();
    for (var move in sampleMoves) {
      addMove(move);
    }
    notifyListeners();
  }

  // Get square type for board initialization
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
        (row == 5 || row == 9) &&
            (col == 1 || col == 5 || col == 9 || col == 13)) {
      return SquareType.tripleLetter;
    }

    // Double Letter Score
    if ((row == 3 || row == 11) && (col == 0 || col == 7 || col == 14) ||
        (row == 6 || row == 8) &&
            (col == 2 || col == 6 || col == 8 || col == 12) ||
        (row == 0 || row == 7 || row == 14) && (col == 3 || col == 11)) {
      return SquareType.doubleLetter;
    }

    return SquareType.normal;
  }

  // Add a new move to the game
  void addMove(Move move) {
    _moves.add(move);

    // Place tiles on board
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

  // Simulate next move
  void simulateNextMove() {
    if (_isGameOver) {
      return;
    }

    final nextMove = MockGameService.simulateNextMove(_currentPlayerId);
    if (nextMove != null) {
      addMove(nextMove);
    } else {
      _isGameOver = true;
      notifyListeners();
    }
  }

  // Restart the game
  void restartGame() {
    MockGameService.resetGame();
    _initializeBoard();
    _initializeGame();
  }

  // Get moves for a specific player
  List<Move> getMovesByPlayer(String playerId) {
    return _moves.where((move) => move.playerId == playerId).toList();
  }

  // Calculate score for a specific player
  int getPlayerScore(String playerId) {
    return _moves
        .where((move) => move.playerId == playerId)
        .fold(0, (sum, move) => sum + move.score);
  }

  // Get current player
  Player getCurrentPlayer() {
    return players.firstWhere((player) => player.id == _currentPlayerId);
  }

  // Check if it's a specific player's turn
  bool isCurrentPlayer(String playerId) {
    return playerId == _currentPlayerId;
  }

  // Calculate points for a specific square
  int getSquarePoints(int row, int col, int basePoints) {
    final squareType = _board[row][col].type;
    switch (squareType) {
      case SquareType.doubleLetter:
        return basePoints * 2;
      case SquareType.tripleLetter:
        return basePoints * 3;
      default:
        return basePoints;
    }
  }

  // Calculate word multiplier for a move
  int getWordMultiplier(List<PlacedTile> tiles) {
    int multiplier = 1;
    for (var tile in tiles) {
      final squareType = _board[tile.row][tile.col].type;
      if (squareType == SquareType.doubleWord) {
        multiplier *= 2;
      } else if (squareType == SquareType.tripleWord) {
        multiplier *= 3;
      }
    }
    return multiplier;
  }

  // Check if a position is occupied
  bool isPositionOccupied(int row, int col) {
    return _board[row][col].tile != null;
  }

  // Get adjacent tiles for a position
  List<Tile?> getAdjacentTiles(int row, int col) {
    List<Tile?> adjacentTiles = [];
    final directions = [(-1, 0), (1, 0), (0, -1), (0, 1)];

    for (var (dRow, dCol) in directions) {
      final newRow = row + dRow;
      final newCol = col + dCol;

      if (newRow >= 0 && newRow < 15 && newCol >= 0 && newCol < 15) {
        adjacentTiles.add(_board[newRow][newCol].tile);
      }
    }

    return adjacentTiles;
  }

  // Getters
  List<List<BoardSquare>> get board => _board;
  List<Move> get moves => _moves;
  String get currentPlayerId => _currentPlayerId;
  bool get isGameOver => _isGameOver;
  int get remainingLetters => MockGameService.getRemainingLettersCount();

  // Get last move
  Move? get lastMove => _moves.isNotEmpty ? _moves.last : null;

  // Get current game statistics
  Map<String, int> getGameStats() {
    return {
      'totalMoves': _moves.length,
      'remainingLetters': remainingLetters,
      'player1Score': getPlayerScore('p1'),
      'player2Score': getPlayerScore('p2'),
    };
  }
}
