import 'package:flutter/material.dart';

extension PlayerListExtension on List<Player> {
  String getDisplayNameById(String playerId) {
    return firstWhere(
      (player) => player.id == playerId,
      orElse: () => Player(
        id: playerId,
        displayName: 'Unknown Player',
        color: Colors.grey,
        imagePath: '',
      ),
    ).displayName;
  }
}

class Player {
  final String id;
  final String displayName;
  final Color color;
  final String imagePath;

  const Player({
    required this.id,
    required this.displayName,
    required this.color,
    required this.imagePath,
  });
}
