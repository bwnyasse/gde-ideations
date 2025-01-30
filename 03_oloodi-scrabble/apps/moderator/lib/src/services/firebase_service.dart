import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oloodi_scrabble_moderator_app/src/services/firebase_error_handler.dart';
import 'package:uuid/uuid.dart';
import '../models/game_session.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: FirebaseFirestore.instance.app,
    databaseId: "scrabble",
  );
  final _uuid = const Uuid();

  Future<GameSession> updateSessionQRCode(String sessionId, String qrCode) async {
    return FirebaseErrorHandler.wrap(
      operation: 'update_session_qr_code',
      action: () async {
        await _firestore
            .collection('game_sessions')
            .doc(sessionId)
            .update({'qrCode': qrCode});

        final doc = await _firestore.collection('game_sessions').doc(sessionId).get();
        return _parseSessionDoc(doc);
      },
    );
  }

  Future<void> updateSessionStatus(String sessionId, bool isActive) async {
    return FirebaseErrorHandler.wrap(
      operation: 'update_session_status',
      action: () async {
        await _firestore
            .collection('game_sessions')
            .doc(sessionId)
            .update({'isActive': isActive});
      },
    );
  }

  Future<GameSession> getSession(String sessionId) async {
    return FirebaseErrorHandler.wrap(
      operation: 'get_session',
      action: () async {
        final doc = await _firestore.collection('game_sessions').doc(sessionId).get();
        if (!doc.exists) {
          throw Exception('Session not found');
        }
        return _parseSessionDoc(doc);
      },
    );
  }

  Stream<List<GameSession>> getActiveSessions() {
    return FirebaseErrorHandler.wrapStream(
      operation: 'get_active_sessions',
      streamAction: () => _firestore
          .collection('game_sessions')
          .where('isActive', isEqualTo: true)
          .orderBy('startTime', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => _parseSessionDoc(doc)).toList();
      }),
    );
  }

  Stream<Map<String, dynamic>> getBoardState(String sessionId) {
    return FirebaseErrorHandler.wrapStream(
      operation: 'get_board_state',
      streamAction: () => _firestore
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
      }),
    );
  }

  Stream<List<Map<String, dynamic>>> getSessionMoves(String sessionId) {
    return FirebaseErrorHandler.wrapStream(
      operation: 'get_session_moves',
      streamAction: () => _firestore
          .collection('game_sessions')
          .doc(sessionId)
          .collection('moves')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          if (data['timestamp'] is Timestamp) {
            data['timestamp'] = (data['timestamp'] as Timestamp).toDate();
          }
          return data;
        }).toList();
      }),
    );
  }

  Stream<int> getPlayerScore(String sessionId, String playerId) {
    return FirebaseErrorHandler.wrapStream(
      operation: 'get_player_score',
      streamAction: () => _firestore
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
      }),
    );
  }

  Future<void> updatePlayerScore(String sessionId, String playerId, int score) async {
    return FirebaseErrorHandler.wrap(
      operation: 'update_player_score',
      action: () async {
        await _firestore.collection('game_sessions').doc(sessionId).update({
          'scores.$playerId': FieldValue.increment(score),
        });
      },
    );
  }

  Future<Map<String, dynamic>?> getMove(String sessionId, String moveId) async {
    return FirebaseErrorHandler.wrap(
      operation: 'get_move',
      action: () async {
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
      },
    );
  }

  Future<void> switchTurn(String sessionId) async {
    return FirebaseErrorHandler.wrap(
      operation: 'switch_turn',
      action: () async {
        final session = await getSession(sessionId);
        final nextPlayerId = session.getNextPlayerId();
        await _firestore
            .collection('game_sessions')
            .doc(sessionId)
            .update({'currentPlayerId': nextPlayerId});
      },
    );
  }

  Future<GameSession> createGameSession({
    required String player1Name,
    required String player2Name,
  }) async {
    return FirebaseErrorHandler.wrap(
      operation: 'create_game_session',
      action: () async {
        final sessionId = _uuid.v4();
        final sessionData = {
          'id': sessionId,
          'player1Name': player1Name,
          'player2Name': player2Name,
          'startTime': FieldValue.serverTimestamp(),
          'isActive': true,
          'currentPlayerId': 'p1',
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
      },
    );
  }

  Future<void> addMoveToSession({
    required String sessionId,
    required String word,
    required int score,
    required String playerId,
    required List<Map<String, dynamic>> tiles,
    String? imagePath,
  }) async {
    return FirebaseErrorHandler.wrap(
      operation: 'add_move_to_session',
      action: () async {
        final batch = _firestore.batch();
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
          'imagePath': imagePath,
        });

        final sessionRef = _firestore.collection('game_sessions').doc(sessionId);
        final session = await getSession(sessionId);

        batch.update(sessionRef, {
          'currentPlayerId': session.getNextPlayerId(),
          'lastMoveImage': imagePath,
        });

        await batch.commit();
      },
    );
  }

  Stream<QuerySnapshot> getGameSessions() {
    return FirebaseErrorHandler.wrapStream(
      operation: 'get_game_sessions',
      streamAction: () => _firestore
          .collection('game_sessions')
          .orderBy('startTime', descending: true)
          .snapshots(),
    );
  }

  Future<void> deleteSession(String sessionId) async {
    return FirebaseErrorHandler.wrap(
      operation: 'delete_session',
      action: () async {
        final movesSnapshot = await _firestore
            .collection('game_sessions')
            .doc(sessionId)
            .collection('moves')
            .get();

        final batch = _firestore.batch();
        for (var doc in movesSnapshot.docs) {
          batch.delete(doc.reference);
        }
        batch.delete(_firestore.collection('game_sessions').doc(sessionId));
        await batch.commit();
      },
    );
  }

  Future<int> getRemainingLetters(String sessionId) async {
    return FirebaseErrorHandler.wrap(
      operation: 'get_remaining_letters',
      action: () async {
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
      },
    );
  }

  Future<void> updateBoardState(String sessionId, List<Map<String, dynamic>> tiles) async {
    return FirebaseErrorHandler.wrap(
      operation: 'update_board_state',
      action: () async {
        final batch = _firestore.batch();
        final boardRef = _firestore
            .collection('game_sessions')
            .doc(sessionId)
            .collection('board_state')
            .doc('current');

        final currentState = await boardRef.get();
        Map<String, dynamic> currentData = currentState.data() ?? {};

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
      },
    );
  }

  Future<Move?> getLastMove(String sessionId) async {
    return FirebaseErrorHandler.wrap(
      operation: 'get_last_move',
      action: () async {
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
      },
    );
  }

  Future<void> switchCurrentPlayer(String sessionId, String playerId) async {
    return FirebaseErrorHandler.wrap(
      operation: 'switch_current_player',
      action: () async {
        await _firestore
            .collection('game_sessions')
            .doc(sessionId)
            .update({'currentPlayerId': playerId});
      },
    );
  }

  Future<int> getMoveCount(String sessionId) async {
    return FirebaseErrorHandler.wrap(
      operation: 'get_move_count',
      action: () async {
        final movesSnapshot = await _firestore
            .collection('game_sessions')
            .doc(sessionId)
            .collection('moves')
            .count()
            .get();

        return movesSnapshot.count ?? 0;
      },
    );
  }

  GameSession _parseSessionDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['startTime'] as Timestamp;

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
}