// lib/src/models/game_session.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class GameSession {
  final String id;
  final String player1Name;
  final String player2Name;
  final DateTime startTime;
  final String currentPlayerId;
  final bool isActive;

  const GameSession({
    required this.id,
    required this.player1Name,
    required this.player2Name,
    required this.startTime,
    this.currentPlayerId = 'p1',
    this.isActive = true,
  });

  factory GameSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameSession(
      id: doc.id,
      player1Name: data['player1Name'] ?? '',
      player2Name: data['player2Name'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      currentPlayerId: data['currentPlayerId'] ?? 'p1',
      isActive: data['isActive'] ?? false,
    );
  }

  String getCurrentPlayerName() {
    return currentPlayerId == 'p1' ? player1Name : player2Name;
  }

  String getNextPlayerId() => currentPlayerId == 'p1' ? 'p2' : 'p1';
}