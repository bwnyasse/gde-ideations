// move.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'game_session.g.dart';

@JsonSerializable()
class Move {
  final String word;
  final int score;
  final List<Map<String, dynamic>> tiles;
  final String playerId;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime timestamp;
  final String? imagePath;

  Move({
    required this.word,
    required this.score,
    required this.tiles,
    required this.playerId,
    required this.timestamp,
    this.imagePath,
  });

  factory Move.fromJson(Map<String, dynamic> json) => _$MoveFromJson(json);
  Map<String, dynamic> toJson() => _$MoveToJson(this);

  static DateTime _timestampFromJson(Timestamp timestamp) => timestamp.toDate();
  static Timestamp _timestampToJson(DateTime date) => Timestamp.fromDate(date);
}

@JsonSerializable()
class GameSession {
  final String id;
  final String player1Name;
  final String player2Name;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime startTime;
  final String? qrCode;
  final String currentPlayerId;
  @JsonKey(defaultValue: [])
  final List<Move> moves;
  final bool isActive;

  GameSession({
    required this.id,
    required this.player1Name,
    required this.player2Name,
    required this.startTime,
    this.qrCode,
    this.currentPlayerId = 'p1',
    this.moves = const [],
    this.isActive = true,
  });

  factory GameSession.fromJson(Map<String, dynamic> json) =>
      _$GameSessionFromJson(json);
  Map<String, dynamic> toJson() => _$GameSessionToJson(this);

  static DateTime _timestampFromJson(Timestamp timestamp) => timestamp.toDate();
  static Timestamp _timestampToJson(DateTime date) => Timestamp.fromDate(date);

  String getNextPlayerId() => currentPlayerId == 'p1' ? 'p2' : 'p1';
  Move? get lastMove => moves.isNotEmpty ? moves.last : null;
}