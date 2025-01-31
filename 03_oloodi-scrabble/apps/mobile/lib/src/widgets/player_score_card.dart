import 'package:flutter/material.dart';
import '../models/player.dart';
import '../themes/app_themes.dart';

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
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? theme.colorScheme.tertiary.withOpacity(0.1)
            : theme.colorScheme.onPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer
              ? theme.colorScheme.tertiary
              : theme.colorScheme.onPrimary.withOpacity(0.1),
          width: isCurrentPlayer ? 2 : 1,
        ),
        boxShadow: [
          if (isCurrentPlayer)
            BoxShadow(
              color: theme.colorScheme.tertiary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(context),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.displayName,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isCurrentPlayer
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.onPrimary.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCurrentPlayer ? 'Current Turn' : 'Waiting',
                          style: TextStyle(
                            color: isCurrentPlayer
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.onPrimary.withOpacity(0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildScoreSection(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(context) {
    final theme = Theme.of(context);
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isCurrentPlayer
              ? theme.colorScheme.tertiary
              : theme.colorScheme.onPrimary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          player.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: theme.colorScheme.onPrimary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: isCurrentPlayer
                    ? theme.colorScheme.tertiary
                    : theme.colorScheme.onPrimary.withOpacity(0.5),
                size: 32,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreSection(context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.stars_rounded,
            color: theme.colorScheme.tertiary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$score',
            style: TextStyle(
              color: theme.colorScheme.tertiary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'points',
            style: TextStyle(
              color: theme.colorScheme.onPrimary.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
