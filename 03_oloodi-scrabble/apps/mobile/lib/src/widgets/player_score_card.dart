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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentPlayer 
          ? AppTheme.accentColor.withOpacity(0.1)
          : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer 
            ? AppTheme.accentColor 
            : Colors.white.withOpacity(0.1),
          width: isCurrentPlayer ? 2 : 1,
        ),
        boxShadow: [
          if (isCurrentPlayer)
            BoxShadow(
              color: AppTheme.accentColor.withOpacity(0.2),
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
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.displayName,
                      style: const TextStyle(
                        color: Colors.white,
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
                              ? AppTheme.accentColor 
                              : Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCurrentPlayer ? 'Current Turn' : 'Waiting',
                          style: TextStyle(
                            color: isCurrentPlayer 
                              ? AppTheme.accentColor 
                              : Colors.white.withOpacity(0.5),
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
          _buildScoreSection(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isCurrentPlayer 
            ? AppTheme.accentColor 
            : Colors.white.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          player.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.white.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: isCurrentPlayer 
                  ? AppTheme.accentColor 
                  : Colors.white.withOpacity(0.5),
                size: 32,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.stars_rounded,
            color: AppTheme.accentColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$score',
            style: const TextStyle(
              color: AppTheme.accentColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'points',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}