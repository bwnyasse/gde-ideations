// lib/src/models/game_session.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class GameSession {
  final String id;
  final String player1Name;
  final String player2Name;
  final DateTime startTime;
  final String? qrCode;
  final String currentPlayerId;  // Added this field
  bool isActive;

  GameSession({
    required this.id,
    required this.player1Name,
    required this.player2Name,
    required this.startTime,
    this.qrCode,
    this.currentPlayerId = 'p1',  // Default to player 1
    this.isActive = true,
  });

  // Optional: Add a factory constructor to create from Firebase data
  factory GameSession.fromMap(Map<String, dynamic> data) {
    return GameSession(
      id: data['id'],
      player1Name: data['player1Name'],
      player2Name: data['player2Name'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      qrCode: data['qrCode'],
      currentPlayerId: data['currentPlayerId'] ?? 'p1',
      isActive: data['isActive'] ?? true,
    );
  }

  // Optional: Add a method to convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'player1Name': player1Name,
      'player2Name': player2Name,
      'startTime': startTime,
      'qrCode': qrCode,
      'currentPlayerId': currentPlayerId,
      'isActive': isActive,
    };
  }

  // Helper method to get the next player's ID
  String getNextPlayerId() {
    return currentPlayerId == 'p1' ? 'p2' : 'p1';
  }
}