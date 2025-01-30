// lib/src/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_session.dart';
import '../models/player.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: FirebaseFirestore.instance.app,
    databaseId: "scrabble",
  );
  String? _gameId;

  // Get active game sessions
  Stream<QuerySnapshot> getActiveSessions() {
    return _firestore
        .collection('game_sessions')
        .where('isActive', isEqualTo: true)
        .orderBy('startTime', descending: true)
        .snapshots();
  }

  // Listen to specific game session
  Stream<DocumentSnapshot> listenToGame(String gameId) {
    _gameId = gameId;
    return _firestore.collection('game_sessions').doc(gameId).snapshots();
  }

  // Listen to moves for a specific game
  Stream<QuerySnapshot> listenToMoves(String gameId) {
    return _firestore
        .collection('game_sessions')
        .doc(gameId)
        .collection('moves')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Get all moves for a game
  Future<QuerySnapshot> getAllMoves(String gameId) async {
    return await _firestore
        .collection('game_sessions')
        .doc(gameId)
        .collection('moves')
        .orderBy('timestamp', descending: false)
        .get();
  }

  // Get players for a specific game
  Future<List<Player>> getPlayers(String gameId) async {
    final gameDoc =
        await _firestore.collection('game_sessions').doc(gameId).get();

    if (!gameDoc.exists) {
      throw Exception('Game not found');
    }

    final data = gameDoc.data() as Map<String, dynamic>;

    return [
      Player(
        id: 'p1',
        displayName: data['player1Name'] ?? 'Player 1',
        color: Colors.blue[300]!,
        imagePath: data['player1Image'] ?? '',
      ),
      Player(
        id: 'p2',
        displayName: data['player2Name'] ?? 'Player 2',
        color: Colors.green[300]!,
        imagePath: data['player2Image'] ?? '',
      ),
    ];
  }

  // Get board state for a game
  Stream<DocumentSnapshot> getBoardState(String gameId) {
    return _firestore
        .collection('game_sessions')
        .doc(gameId)
        .collection('board_state')
        .doc('current')
        .snapshots();
  }

  // Get session statistics
  Future<Map<String, dynamic>> getSessionStats(String gameId) async {
    try {
      final movesSnapshot = await _firestore
          .collection('game_sessions')
          .doc(gameId)
          .collection('moves')
          .get();

      final moves = movesSnapshot.docs;
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

  // Get player score
  Stream<int> getPlayerScore(String gameId, String playerId) {
    return _firestore
        .collection('game_sessions')
        .doc(gameId)
        .collection('moves')
        .where('playerId', isEqualTo: playerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .fold(0, (sum, doc) => sum + (doc.data()['score'] as int? ?? 0)));
  }

  // Get remaining letters
  Future<Map<String, int>> getRemainingLetters(String gameId) async {
    final doc = await _firestore
        .collection('game_sessions')
        .doc(gameId)
        .collection('game_state')
        .doc('letters')
        .get();

    if (!doc.exists) {
      return {}; // Return empty map if no letter data exists
    }

    final data = doc.data() as Map<String, dynamic>;
    return Map<String, int>.from(data['distribution'] ?? {});
  }

  // Get game session by ID
  Future<GameSession?> getSession(String gameId) async {
    final doc = await _firestore.collection('game_sessions').doc(gameId).get();

    if (!doc.exists) {
      return null;
    }

    return GameSession.fromFirestore(doc);
  }
}
