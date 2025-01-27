import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/player.dart';
import 'package:oloodi_scrabble_end_user_app/src/themes/app_themes.dart';
class PlayerScoreCard extends StatelessWidget {
  final Player player;
  final int score;
  final bool isCurrentPlayer;

  const PlayerScoreCard({
    super.key,
    required this.player,
    required this.score,
    required this.isCurrentPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentPlayer ? AppTheme.accentColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Player image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.accentColor,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                player.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.white24,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Score: $score',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}