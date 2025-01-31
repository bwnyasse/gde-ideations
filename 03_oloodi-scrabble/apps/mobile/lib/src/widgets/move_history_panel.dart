import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/game_state_provider.dart';
import 'package:provider/provider.dart';

class MoveHistoryPanel extends StatelessWidget {
  const MoveHistoryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        final distribution = gameState.letterDistribution;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Move History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Tooltip(
                    message: distribution.entries
                        .where((e) => e.value > 0)
                        .map((e) => '${e.key}: ${e.value}')
                        .join('\n'),
                    child: Text(
                      'Remaining: ${gameState.remainingLetters}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: gameState.moves.length,
                itemBuilder: (context, index) {
                  final move = gameState.moves[index];
                  final player = gameState.players.firstWhere(
                    (p) => p.id == move.playerId,
                  );

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: player.color,
                      child: Text(
                        move.word[0],
                        style: TextStyle(color: theme.colorScheme.onPrimary),
                      ),
                    ),
                    title: Text(move.word),
                    subtitle:
                        Text('${player.displayName} - ${move.score} points'),
                    trailing: Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
