import 'package:flutter/material.dart';

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
