// lib/src/providers/game_state_provider.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/move_explanation.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/settings_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/service/ai_service.dart';
import '../models/game_session.dart';
import '../models/board_square.dart';
import '../models/move.dart';
import '../models/tile.dart';
import '../models/player.dart';
import '../service/firebase_service.dart';

class GameStateProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  late AIService _aiService;
  final SettingsProvider _settings;
  Map<String, MoveExplanation> _moveExplanations = {};

  // Game state
  List<List<BoardSquare>> _board = [];
  List<Move> _moves = [];
  List<Player> _players = [];
  String? _currentPlayerId;
  bool _isGameOver = false;
  String? _gameId;

  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  // Add getters
  bool get isPlaying => _isPlaying;

  // Subscriptions
  StreamSubscription? _gameSubscription;
  StreamSubscription? _movesSubscription;

  // Constructor
  GameStateProvider(AIService aiService, SettingsProvider settings)
      : _aiService = aiService,
        _settings = settings {
    _initializeBoard();
    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      debugPrint('Audio player state changed: $state');
    });
  }

  String getPlayerNameById(Color color, String playerId) {
    return _players
        .firstWhere(
          (player) => player.id == playerId,
          orElse: () => Player(
            id: playerId,
            displayName: 'Unknown Player',
            color: color,
            imagePath: '',
          ),
        )
        .displayName;
  }

  // Add these methods
  Future<MoveExplanation> explainMove(Color color, Move move) async {
    // Check if we already have an explanation
    if (_moveExplanations.containsKey(move.word)) {
      return _moveExplanations[move.word]!;
    }

    try {
      final currentScore = getPlayerScore(move.playerId);
      final playerName = getPlayerNameById(color, move.playerId);

      final explanation = await _aiService.generateMoveExplanation(
        playerName,
        move,
        currentScore,
      );

      // Convert to speech in parallel
      final audioData =
          await _aiService.convertToSpeech(explanation, _settings.language);

      final moveExplanation = MoveExplanation(
        text: explanation,
        audioData: audioData,
      );

      _moveExplanations[move.word] = moveExplanation;
      notifyListeners();

      return moveExplanation;
    } catch (e) {
      throw Exception('Failed to explain move: $e');
    }
  }

  MoveExplanation? getExplanation(String word) => _moveExplanations[word];

  // Get available game sessions
  Stream<List<GameSession>> getAvailableSessions() {
    return _firebaseService.getActiveSessions().map((snapshot) =>
        snapshot.docs.map((doc) => GameSession.fromFirestore(doc)).toList());
  }

  // Initialize game with session ID
  Future<void> initializeGame(String gameId) async {
    try {
      _gameId = gameId;
      _initializeBoard();
      _moves.clear();

      // Listen to game document updates
      _gameSubscription =
          _firebaseService.listenToGame(gameId).listen((snapshot) {
        final gameData = snapshot.data() as Map<String, dynamic>;
        _updateGameInfo(gameData);
      });

      // Listen to moves collection
      _movesSubscription =
          _firebaseService.listenToMoves(gameId).listen((snapshot) {
        _handleMovesUpdate(snapshot);
      });

      notifyListeners();
    } catch (e) {
      print('Error initializing game: $e');
      rethrow;
    }
  }

  // Handle moves updates
  void _handleMovesUpdate(QuerySnapshot snapshot) {
    // Handle deletions or out-of-order moves
    if (snapshot.docChanges.any((change) =>
        change.type == DocumentChangeType.removed ||
        change.type == DocumentChangeType.modified)) {
      _rebuildBoardState(snapshot.docs);
    } else {
      // Handle only new moves
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final move = Move.fromFirestore(change.doc);
          _addMove(move);
        }
      }
    }
  }

  // Rebuild entire board state
  void _rebuildBoardState(List<QueryDocumentSnapshot> docs) {
    _initializeBoard();
    _moves.clear();

    // Reapply all moves in order
    for (var doc in docs) {
      final move = Move.fromFirestore(doc);
      _addMove(move);
    }
  }

  // Manual board update (fallback method)
  Future<void> updateBoard() async {
    if (_gameId == null) throw Exception('No active game session');

    try {
      final movesSnapshot = await _firebaseService.getAllMoves(_gameId!);
      _rebuildBoardState(movesSnapshot.docs);
    } catch (e) {
      print('Error updating board: $e');
      rethrow;
    }
  }

  // Get session statistics
  Future<Map<String, dynamic>> getSessionStats(String sessionId) async {
    return _firebaseService.getSessionStats(sessionId);
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

  // Calculate remaining letters based on played moves
  Map<String, int> get letterDistribution {
    Map<String, int> remaining = Map.from(_initialLetterDistribution);

    for (var move in _moves) {
      for (var tile in move.tiles) {
        if (remaining.containsKey(tile.letter)) {
          remaining[tile.letter] = remaining[tile.letter]! - 1;
        }
      }
    }

    return remaining;
  }

  // Get total remaining letters
  int get remainingLetters {
    return letterDistribution.values.fold(0, (sum, count) => sum + count);
  }

  // Initialize empty board
  void _initializeBoard() {
    _board = List.generate(15, (row) {
      return List.generate(15, (col) {
        return BoardSquare(
          row: row,
          col: col,
          type: getSquareType(row, col),
        );
      });
    });
    notifyListeners();
  }

  // Update game information
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

// Helper method to add moves
  void _addMove(Move move) {
    _moves.add(move);

    // Store existing tiles before placing new ones
    Map<String, Tile> existingTiles = {};
    for (int row = 0; row < 15; row++) {
      for (int col = 0; col < 15; col++) {
        if (_board[row][col].tile != null) {
          String key = '${row}-${col}';
          existingTiles[key] = _board[row][col].tile!;
        }
      }
    }

    // Place new tiles
    for (var tile in move.tiles) {
      String key = '${tile.row}-${tile.col}';
      _board[tile.row][tile.col].tile = Tile(
        letter: tile.letter,
        points: tile.points,
        playerId: move.playerId,
        isNew: true,
      );
      // Remove from existing tiles if we just overwrote it
      existingTiles.remove(key);
    }

    // Restore existing tiles that weren't overwritten
    existingTiles.forEach((key, tile) {
      final coords = key.split('-');
      final row = int.parse(coords[0]);
      final col = int.parse(coords[1]);
      if (_board[row][col].tile == null) {
        _board[row][col].tile = tile;
      }
    });

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

  // Letter distribution constants (French Scrabble distribution)
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
    '*': 2, // Blank tiles
  };

  // Getters
  List<List<BoardSquare>> get board => _board;
  List<Move> get moves => _moves;
  List<Player> get players => _players;
  String? get currentPlayerId => _currentPlayerId;
  bool get isGameOver => _isGameOver;
  Move? get lastMove => _moves.isNotEmpty ? _moves.last : null;

  @override
  void dispose() {
    _gameSubscription?.cancel();
    _movesSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> handleMoveExplanation(Color color, Move move) async {
    if (_isPlaying) {
      _isPlaying = false;
      await _audioPlayer.stop();
      notifyListeners();
      return;
    }

    try {
      // Get the explanation first
      final explanation = await _aiService.generateMoveExplanation(
        getPlayerNameById(color, move.playerId),
        move,
        getPlayerScore(move.playerId),
      );

      // Convert to speech
      final audioData =
          await _aiService.convertToSpeech(explanation, _settings.language);

      // Ensure audioData is not null and not empty
      if (audioData.isEmpty) {
        throw Exception('No audio data received');
      }

      // Create the audio source
      final source = BytesSource(Uint8List.fromList(audioData));

      // Set up completion listener
      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
        notifyListeners();
      });

      // Play the audio
      await _audioPlayer.play(source);
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Audio playback error: $e');
      _isPlaying = false;
      notifyListeners();
      throw Exception('Failed to play move explanation: $e');
    }
  }
}
