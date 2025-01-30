// lib/src/providers/game_state_provider.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_session.dart';
import '../models/board_square.dart';
import '../models/move.dart';
import '../models/tile.dart';
import '../models/player.dart';

class GameStateProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Constructor
  GameStateProvider() {
    _initializeBoard();
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

  // Get available game sessions
  Stream<List<GameSession>> getAvailableSessions() {
    return _firestore
        .collection('game_sessions')
        .where('isActive', isEqualTo: true)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GameSession.fromFirestore(doc))
            .toList());
  }

  // Initialize board
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

  // Get total remaining letters
  int get remainingLetters {
    return letterDistribution.values.fold(0, (sum, count) => sum + count);
  }

  // Manual board update (fallback method)
  Future<void> updateBoard() async {
    if (_gameId == null) {
      throw Exception('No active game session');
    }

    try {
      // Re-fetch all moves from Firebase
      final movesSnapshot = await _firestore
          .collection('game_sessions')
          .doc(_gameId)
          .collection('moves')
          .orderBy('timestamp', descending: false)
          .get();

      // Clear current board and moves
      _initializeBoard();
      _moves.clear();

      // Reapply all moves in order
      for (var doc in movesSnapshot.docs) {
        final move = Move.fromFirestore(doc);
        _addMove(move);
      }

      notifyListeners();
    } catch (e) {
      print('Error updating board: $e');
      rethrow;
    }
  }

  // Initialize game with session ID
  Future<void> initializeGame(String gameId) async {
    try {
      _gameId = gameId;
      _initializeBoard();
      _moves.clear();

      // Listen to game document for player information and game status
      _gameSubscription = _firestore
          .collection('game_sessions')
          .doc(gameId)
          .snapshots()
          .listen((snapshot) {
        final gameData = snapshot.data() as Map<String, dynamic>;
        _updateGameInfo(gameData);
      });

      // Listen to moves collection
      _movesSubscription = _firestore
          .collection('game_sessions')
          .doc(gameId)
          .collection('moves')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .listen((snapshot) {
        // Handle deletions or out-of-order moves
        if (snapshot.docChanges.any((change) =>
            change.type == DocumentChangeType.removed ||
            change.type == DocumentChangeType.modified)) {
          // Rebuild entire board state
          _initializeBoard();
          _moves.clear();

          // Reapply all moves in order
          for (var doc in snapshot.docs) {
            final move = Move.fromFirestore(doc);
            _addMove(move);
          }
        } else {
          // Handle only new moves
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final move = Move.fromFirestore(change.doc);
              _addMove(move);
            }
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
        color: Colors.blue[300]!,
        imagePath: gameData['player1Image'] ?? '',
      ),
      Player(
        id: 'p2',
        displayName: gameData['player2Name'],
        color: Colors.green[300]!,
        imagePath: gameData['player2Image'] ?? '',
      ),
    ];

    _currentPlayerId = gameData['currentPlayerId'];
    _isGameOver = gameData['isGameOver'] ?? false;

    notifyListeners();
  }

  // Get square type for board initialization
  SquareType _getSquareType(int row, int col) {
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

  // Helper method to add moves
  void _addMove(Move move) {
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

  // Get session statistics
  Future<Map<String, dynamic>> getSessionStats(String sessionId) async {
    try {
      final movesSnapshot = await _firestore
          .collection('game_sessions')
          .doc(sessionId)
          .collection('moves')
          .get();

      final moves = movesSnapshot.docs;

      // Calculate remaining letters (this is a simplified version)
      final remainingLetters = 100 - moves.length * 7; // Approximate

      return {
        'totalMoves': moves.length,
        'remainingLetters': remainingLetters > 0 ? remainingLetters : 0,
        'player1Score': moves
            .where((m) => m.data()['playerId'] == 'p1')
            .fold(0, (sum, m) => sum + (m.data()['score'] as int)),
        'player2Score': moves
            .where((m) => m.data()['playerId'] == 'p2')
            .fold(0, (sum, m) => sum + (m.data()['score'] as int)),
      };
    } catch (e) {
      print('Error getting session stats: $e');
      rethrow;
    }
  }

  // Static letter distribution (French Scrabble)
  static const Map<String, int> _initialLetterDistribution = {
    'A': 9,
    'B': 2,
    'C': 2,
    'D': 3,
    'E': 15,
    'F': 2,
    'G': 2,
    'H': 2,
    'I': 8,
    'J': 1,
    'K': 1,
    'L': 5,
    'M': 3,
    'N': 6,
    'O': 6,
    'P': 2,
    'Q': 1,
    'R': 6,
    'S': 6,
    'T': 6,
    'U': 6,
    'V': 2,
    'W': 1,
    'X': 1,
    'Y': 1,
    'Z': 1,
    '*': 2,
  };

  // Calculate remaining letters based on played moves
  Map<String, int> get letterDistribution {
    // Start with the initial distribution
    Map<String, int> remaining = Map.from(_initialLetterDistribution);

    // Subtract letters used in moves
    for (var move in _moves) {
      for (var tile in move.tiles) {
        if (remaining.containsKey(tile.letter)) {
          remaining[tile.letter] = remaining[tile.letter]! - 1;
        }
      }
    }

    return remaining;
  }

  // Getters
  List<List<BoardSquare>> get board => _board;
  List<Move> get moves => _moves;
  List<Player> get players => _players;
  String? get currentPlayerId => _currentPlayerId;
  bool get isGameOver => _isGameOver;
  Move? get lastMove => _moves.isNotEmpty ? _moves.last : null;

  // Cleanup
  @override
  void dispose() {
    _gameSubscription?.cancel();
    _movesSubscription?.cancel();
    super.dispose();
  }
}
