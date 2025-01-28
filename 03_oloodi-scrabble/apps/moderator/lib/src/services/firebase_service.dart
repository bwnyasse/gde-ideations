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

  // Parse Firestore document to GameSession
  GameSession _parseSessionDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['startTime'] as Timestamp;

    return GameSession(
      id: doc.id,
      player1Name: data['player1Name'],
      player2Name: data['player2Name'],
      startTime: timestamp.toDate(),
      qrCode: data['qrCode'],
      isActive: data['isActive'] ?? false,
    );
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

  // Update board state
  Future<void> updateBoardState(
      String sessionId, Map<String, dynamic> boardState) async {
    await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .collection('board_state')
        .doc('current')
        .set(boardState, SetOptions(merge: true));
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

  // Update your addMoveToSession method to handle turn switching
  Future<void> addMoveToSession({
    required String sessionId,
    required String word,
    required int score,
    required String playerId,
    required List<Map<String, dynamic>> tiles,
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
    });

    // Switch to next player
    final sessionRef = _firestore.collection('game_sessions').doc(sessionId);

    final session = await getSession(sessionId);
    batch.update(sessionRef, {
      'currentPlayerId': session.getNextPlayerId(),
    });

    await batch.commit();
  }
}
