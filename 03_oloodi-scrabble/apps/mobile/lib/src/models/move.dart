// lib/src/models/move.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'move.g.dart';

@JsonSerializable()
class Move {
  final String word;
  final int score;
  final List<PlacedTile> tiles;
  final String playerId;
  final DateTime timestamp;

  Move({
    required this.word,
    required this.score,
    required this.tiles,
    required this.playerId,
    required this.timestamp,
  });

  factory Move.fromJson(Map<String, dynamic> json) => _$MoveFromJson(json);
  
  factory Move.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Move(
      word: data['word'] ?? '',
      score: data['score'] ?? 0,
      tiles: (data['tiles'] as List<dynamic>?)
          ?.map((tile) => PlacedTile(
                letter: tile['letter'],
                row: tile['row'],
                col: tile['col'],
                points: tile['points'],
              ))
          .toList() ?? [],
      playerId: data['playerId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => _$MoveToJson(this);
}

@JsonSerializable()
class PlacedTile {
  final String letter;
  final int row;
  final int col;
  final int points;

  PlacedTile({
    required this.letter,
    required this.row,
    required this.col,
    required this.points,
  });

  factory PlacedTile.fromJson(Map<String, dynamic> json) => _$PlacedTileFromJson(json);
  Map<String, dynamic> toJson() => _$PlacedTileToJson(this);
}