import 'package:json_annotation/json_annotation.dart';

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
