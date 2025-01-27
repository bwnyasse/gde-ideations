class Tile {
  final String letter;
  final int points;
  final String playerId;
  bool isNew;

  Tile({
    required this.letter,
    required this.points,
    required this.playerId,
    this.isNew = false,
  });
}
