// lib/src/models/game_session.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class GameSession {
  final String id;
  final String player1Name;
  final String player2Name;
  final DateTime startTime;
  final String? qrCode;
  final String currentPlayerId;
  final String? lastMoveImagePath;
  final List<Map<String, dynamic>> moves; // Added moves list
  bool isActive;

  GameSession({
    required this.id,
    required this.player1Name,
    required this.player2Name,
    required this.startTime,
    this.qrCode,
    this.currentPlayerId = 'p1',
    this.lastMoveImagePath,
    this.moves = const [], // Initialize with empty list by default
    this.isActive = true,
  });

  // Update the fromMap factory constructor
  factory GameSession.fromMap(Map<String, dynamic> data) {
    // Convert moves data if it exists
    List<Map<String, dynamic>> movesList = [];
    if (data['moves'] != null) {
      movesList = List<Map<String, dynamic>>.from(data['moves']);
    }

    return GameSession(
      id: data['id'],
      player1Name: data['player1Name'],
      player2Name: data['player2Name'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      qrCode: data['qrCode'],
      currentPlayerId: data['currentPlayerId'] ?? 'p1',
      lastMoveImagePath: data['lastMoveImage'],
      moves: movesList, // Add moves to constructor
      isActive: data['isActive'] ?? true,
    );
  }

  // Update the toMap method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'player1Name': player1Name,
      'player2Name': player2Name,
      'startTime': startTime,
      'qrCode': qrCode,
      'currentPlayerId': currentPlayerId,
      'lastMoveImage': lastMoveImagePath,
      'moves': moves, // Include moves in the map
      'isActive': isActive,
    };
  }

  String getNextPlayerId() {
    return currentPlayerId == 'p1' ? 'p2' : 'p1';
  }
}
