// lib/providers/game_state_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oloodi_scrabble_end_user_app/src/service/firebase_service.dart';
import '../models/board_square.dart';
import '../models/move.dart';
import '../models/tile.dart';
import '../models/player.dart';

class GameStateProvider with ChangeNotifier {
  // Services
  final FirebaseService _firebaseService = FirebaseService();

  // Game state
  List<List<BoardSquare>> _board = [];
  List<Move> _moves = [];
  List<Player> _players = [];
  String? _currentPlayerId;
  bool _isGameOver = false;
  String? _gameId;

  // Subscriptions
  StreamSubscription? _gameSubscription;
  StreamSubscription? _movesSubscription;

  static const Map<String, int> _initialLetterDistribution = {
    'A': 9, 'B': 2, 'C': 2, 'D': 3, 'E': 15,
    'F': 2, 'G': 2, 'H': 2, 'I': 8, 'J': 1,
    'K': 1, 'L': 5, 'M': 3, 'N': 6, 'O': 6,
    'P': 2, 'Q': 1, 'R': 6, 'S': 6, 'T': 6,
    'U': 6, 'V': 2, 'W': 1, 'X': 1, 'Y': 1,
    'Z': 1, '*': 2, // '*' represents blank/joker tiles
  };

  Map<String, int> _remainingLetters = Map.from(_initialLetterDistribution);

  // Constructor
  GameStateProvider() {
    _initializeBoard();
  }

  // Initialize empty board
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
    notifyListeners();
  }

  // Initialize game with QR code data
  Future<void> initializeGame(String gameId) async {
    try {
      _gameId = gameId;

      // Listen to game document for player information and game status
      _gameSubscription =
          _firebaseService.listenToGame(gameId).listen((snapshot) {
        final gameData = snapshot.data() as Map<String, dynamic>;
        _updateGameInfo(gameData);
      });

      // Listen to moves collection
      _movesSubscription = _firebaseService.listenToMoves().listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final moveData = change.doc.data() as Map<String, dynamic>;
            final move = Move.fromJson(moveData);
            _addMove(move);
          }
        }
      });

      notifyListeners();
    } catch (e) {
      print('Error initializing game: $e');
      rethrow;
    }
  }

  // Update game information from Firebase
  void _updateGameInfo(Map<String, dynamic> gameData) {
    _players = [
      Player(
        id: 'p1',
        displayName: gameData['player1Name'],
        color: Color(gameData['player1Color']),
        imagePath: gameData['player1Image'],
      ),
      Player(
        id: 'p2',
        displayName: gameData['player2Name'],
        color: Color(gameData['player2Color']),
        imagePath: gameData['player2Image'],
      ),
    ];

    _currentPlayerId = gameData['currentPlayerId'];
    _isGameOver = gameData['isGameOver'] ?? false;

    // Update remaining letters if provided in gameData
    if (gameData.containsKey('remainingLetters')) {
      _remainingLetters = Map<String, int>.from(gameData['remainingLetters']);
    }

    notifyListeners();
  }

  // Get square type for board initialization
  SquareType _getSquareType(int row, int col) {
    // Center square - acts as Double Word Score
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
        (row == 0 || row == 7 || row == 14) && (col == 3 || col == 11)) {
      return SquareType.doubleLetter;
    }

    return SquareType.normal;
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
    return _players.firstWhere(
      (player) => player.id == _currentPlayerId,
      orElse: () => _players.first,
    );
  }

  // Check if it's a specific player's turn
  bool isCurrentPlayer(String playerId) {
    return playerId == _currentPlayerId;
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

  // Cleanup
  @override
  void dispose() {
    _gameSubscription?.cancel();
    _movesSubscription?.cancel();
    super.dispose();
  }

  // Getters
  List<List<BoardSquare>> get board => _board;
  List<Move> get moves => _moves;
  List<Player> get players => _players;
  String? get currentPlayerId => _currentPlayerId;
  bool get isGameOver => _isGameOver;
  Move? get lastMove => _moves.isNotEmpty ? _moves.last : null;

  // Get current game statistics
  Map<String, int> getGameStats() {
    return {
      'totalMoves': _moves.length,
      'player1Score': getPlayerScore('p1'),
      'player2Score': getPlayerScore('p2'),
    };
  }

  // Fetch current state from Firebase and rebuild board
  Future<void> updateBoard() async {
    if (_gameId == null) {
      throw Exception('No active game session');
    }

    try {
      // Get all moves from Firebase in order
      final movesSnapshot = await _firebaseService.getAllMoves(_gameId!);

      // Clear current board
      _initializeBoard();
      _moves.clear();

      // Reapply all moves in order
      for (var doc in movesSnapshot.docs) {
        final moveData = doc.data() as Map<String, dynamic>;
        final move = Move.fromJson(moveData);
        _addMove(move);
      }

      notifyListeners();
    } catch (e) {
      print('Error updating board: $e');
      rethrow;
    }
  }

  // This will be implemented later to create new game session
  Future<void> restartGame() async {
    // For now, just throw not implemented
    throw UnimplementedError(
        'Restart game will be implemented in future version');

    // Future implementation will look something like this:
    /*
    if (_gameId == null) {
      throw Exception('No active game session');
    }

    try {
      // Create new game session in Firebase
      await _firebaseService.createNewSession(_gameId!);
      
      // Reset local state
      _initializeBoard();
      _moves.clear();
      _isGameOver = false;
      
      notifyListeners();
    } catch (e) {
      print('Error restarting game: $e');
      rethrow;
    }
    */
  }

  // Helper method to properly add moves to the board
  void _addMove(Move move) {
    _moves.add(move);

    // Update remaining letters based on the move
    for (var tile in move.tiles) {
      if (_remainingLetters.containsKey(tile.letter)) {
        _remainingLetters[tile.letter] = _remainingLetters[tile.letter]! - 1;
      }
    }

    // Place tiles on board
    for (var tile in move.tiles) {
      _board[tile.row][tile.col].tile = Tile(
        letter: tile.letter,
        points: tile.points,
        playerId: move.playerId,
        isNew: true,
      );
    }

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

  // Add getter for remainingLetters
  int get remainingLetters {
    return _remainingLetters.values.fold(0, (sum, count) => sum + count);
  }

  // Optional: Add getter for detailed letter distribution
  Map<String, int> get letterDistribution =>
      Map.unmodifiable(_remainingLetters);
}
