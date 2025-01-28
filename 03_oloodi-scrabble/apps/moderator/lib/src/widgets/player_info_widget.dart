// lib/src/widgets/player_info_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_session_provider.dart';
import '../services/firebase_service.dart';

class PlayerInfoWidget extends StatelessWidget {
  final String player1Name;
  final String player2Name;

  const PlayerInfoWidget({
    super.key,
    required this.player1Name,
    required this.player2Name,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildPlayerInfo(
                context,
                name: player1Name,
                playerId: 'p1',
                color: Colors.blue[300]!,
              ),
            ),
            Container(
              height: 40,
              width: 2,
              color: Colors.grey[300],
            ),
            Expanded(
              child: _buildPlayerInfo(
                context,
                name: player2Name,
                playerId: 'p2',
                color: Colors.green[300]!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(
    BuildContext context, {
    required String name,
    required String playerId,
    required Color color,
  }) {
    return StreamBuilder<int>(
      stream: FirebaseService().getPlayerScore(
        context.read<GameSessionProvider>().currentSession!.id,
        playerId,
      ),
      builder: (context, snapshot) {
        final score = snapshot.data ?? 0;
        final isCurrentPlayer = context.select(
          (GameSessionProvider p) => p.currentSession?.currentPlayerId == playerId,
        );

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isCurrentPlayer
                ? Border.all(color: color, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: color,
                    radius: 16,
                    child: Text(
                      name[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Score: $score',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (isCurrentPlayer) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Current Turn',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}