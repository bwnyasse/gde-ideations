// lib/src/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/game_session.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: FirebaseFirestore.instance.app,
    databaseId: "scrabble",
  );
  final _uuid = const Uuid();

  // Update session QR code
  Future<GameSession> updateSessionQRCode(
    String sessionId,
    String qrCode,
  ) async {
    await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .update({'qrCode': qrCode});

    final doc =
        await _firestore.collection('game_sessions').doc(sessionId).get();

    return _parseSessionDoc(doc);
  }

  // Update session status
  Future<void> updateSessionStatus(
    String sessionId,
    bool isActive,
  ) async {
    await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .update({'isActive': isActive});
  }

  // Get session by ID
  Future<GameSession> getSession(String sessionId) async {
    final doc =
        await _firestore.collection('game_sessions').doc(sessionId).get();

    if (!doc.exists) {
      throw Exception('Session not found');
    }

    return _parseSessionDoc(doc);
  }

  // Get active sessions
  Stream<List<GameSession>> getActiveSessions() {
    return _firestore
        .collection('game_sessions')
        .where('isActive', isEqualTo: true)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _parseSessionDoc(doc)).toList();
    });
  }

// Get real-time board state updates
  Stream<Map<String, dynamic>> getBoardState(String sessionId) {
    return _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .collection('board_state')
        .doc('current')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return {};
      }
      return snapshot.data() as Map<String, dynamic>;
    });
  }

  // Get real-time session moves
  Stream<List<Map<String, dynamic>>> getSessionMoves(String sessionId) {
    return _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .collection('moves')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Convert Timestamp to DateTime
        if (data['timestamp'] is Timestamp) {
          data['timestamp'] = (data['timestamp'] as Timestamp).toDate();
        }
        return data;
      }).toList();
    });
  }

  // Get real-time player score
  Stream<int> getPlayerScore(String sessionId, String playerId) {
    return _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .collection('moves')
        .where('playerId', isEqualTo: playerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.fold<int>(
        0,
        (sum, doc) => sum + (doc.data()['score'] as int? ?? 0),
      );
    });
  }

  // Update player score (if needed separately from moves)
  Future<void> updatePlayerScore(
      String sessionId, String playerId, int score) async {
    await _firestore.collection('game_sessions').doc(sessionId).update({
      'scores.$playerId': FieldValue.increment(score),
    });
  }

  // Get single move by ID
  Future<Map<String, dynamic>?> getMove(String sessionId, String moveId) async {
    final doc = await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .collection('moves')
        .doc(moveId)
        .get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    if (data['timestamp'] is Timestamp) {
      data['timestamp'] = (data['timestamp'] as Timestamp).toDate();
    }
    return data;
  }

  // Switch to next player's turn
  Future<void> switchTurn(String sessionId) async {
    final session = await getSession(sessionId);
    final nextPlayerId = session.getNextPlayerId();

    await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .update({'currentPlayerId': nextPlayerId});
  }

  // Update your createGameSession method to include currentPlayerId
  Future<GameSession> createGameSession({
    required String player1Name,
    required String player2Name,
  }) async {
    final sessionId = _uuid.v4();
    final sessionData = {
      'id': sessionId,
      'player1Name': player1Name,
      'player2Name': player2Name,
      'startTime': FieldValue.serverTimestamp(),
      'isActive': true,
      'currentPlayerId': 'p1', // Start with player 1
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .set(sessionData);

    return GameSession(
      id: sessionId,
      player1Name: player1Name,
      player2Name: player2Name,
      startTime: DateTime.now(),
      currentPlayerId: 'p1',
      isActive: true,
    );
  }

  Future<String?> getLastMoveImage(String sessionId) async {
    try {
      final querySnapshot = await _firestore
          .collection('game_sessions')
          .doc(sessionId)
          .collection('moves')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final moveData = querySnapshot.docs.first.data();
      return moveData['imagePath'] as String?;
    } catch (e) {
      print('Error getting last move image: $e');
      return null;
    }
  }

  // Update the addMoveToSession method to include the image path
  Future<void> addMoveToSession({
    required String sessionId,
    required String word,
    required int score,
    required String playerId,
    required List<Map<String, dynamic>> tiles,
    String? imagePath, // Add this parameter
  }) async {
    final batch = _firestore.batch();

    // Add the move
    final moveRef = _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .collection('moves')
        .doc();

    batch.set(moveRef, {
      'word': word,
      'score': score,
      'playerId': playerId,
      'tiles': tiles,
      'timestamp': FieldValue.serverTimestamp(),
      'imagePath': imagePath, // Store the image path
    });

    // Switch to next player
    final sessionRef = _firestore.collection('game_sessions').doc(sessionId);
    final session = await getSession(sessionId);

    batch.update(sessionRef, {
      'currentPlayerId': session.getNextPlayerId(),
      'lastMoveImage': imagePath, // Also store in session for quick access
    });

    await batch.commit();
  }

  Stream<QuerySnapshot> getGameSessions() {
    return _firestore
        .collection('game_sessions')
        .orderBy('startTime', descending: true)
        .snapshots();
  }

  // Delete a session and all its subcollections
  Future<void> deleteSession(String sessionId) async {
    // Delete moves subcollection
    final movesSnapshot = await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .collection('moves')
        .get();

    final batch = _firestore.batch();

    for (var doc in movesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete main session document
    batch.delete(_firestore.collection('game_sessions').doc(sessionId));

    await batch.commit();
  }

  // Get remaining letters
  Future<int> getRemainingLetters(String sessionId) async {
    final doc = await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .collection('game_state')
        .doc('letters')
        .get();

    if (!doc.exists) {
      return 0;
    }

    final data = doc.data() as Map<String, dynamic>;
    return data['remaining'] ?? 0;
  }

  // Update the board state with new tiles
  Future<void> updateBoardState(
      String sessionId, List<Map<String, dynamic>> tiles) async {
    final batch = _firestore.batch();
    final boardRef = _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .collection('board_state')
        .doc('current');

    // Get current board state
    final currentState = await boardRef.get();
    Map<String, dynamic> currentData = currentState.data() ?? {};

    // Update with new tiles
    for (var tile in tiles) {
      String key = '${tile['row']}-${tile['col']}';
      currentData[key] = {
        'letter': tile['letter'],
        'points': tile['points'],
        'playerId': tile['playerId'],
      };
    }

    batch.set(boardRef, currentData, SetOptions(merge: true));
    await batch.commit();
  }

// Update the session with the last move's image path
  Future<void> updateSessionImage(String sessionId, String imagePath) async {
    await _firestore.collection('game_sessions').doc(sessionId).update({
      'lastMoveImage': imagePath,
    });
  }

  GameSession _parseSessionDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['startTime'] as Timestamp;

    // Get moves from the document if they exist
    List<Move> moves = [];
    if (data['moves'] != null) {
      moves = (data['moves'] as List)
          .map((moveData) => Move.fromJson(moveData))
          .toList();
    }

    return GameSession(
      id: doc.id,
      player1Name: data['player1Name'],
      player2Name: data['player2Name'],
      startTime: timestamp.toDate(),
      qrCode: data['qrCode'],
      isActive: data['isActive'] ?? false,
      currentPlayerId: data['currentPlayerId'] ?? 'p1',
      moves: moves,
    );
  }

  Future<Move?> getLastMove(String sessionId) async {
    try {
      final querySnapshot = await _firestore
          .collection('game_sessions')
          .doc(sessionId)
          .collection('moves')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return Move.fromJson(querySnapshot.docs.first.data());
    } catch (e) {
      print('Error getting last move: $e');
      return null;
    }
  }

  Future<void> switchCurrentPlayer(String sessionId, String playerId) async {
    await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .update({'currentPlayerId': playerId});
  }

    Future<int> getMoveCount(String sessionId) async {
    final movesSnapshot = await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .collection('moves')
        .count()
        .get();
    
    return movesSnapshot.count ?? 0;
  }
}
