import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/player.dart';
import 'package:intl/intl.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/game_state_provider.dart';
import 'package:provider/provider.dart';

class PlayerHistorySheet extends StatelessWidget {
  final Player player;

  const PlayerHistorySheet({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: player.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${player.displayName}\'s Moves',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<GameStateProvider>(
              builder: (context, gameState, child) {
                final moves = gameState.getMovesByPlayer(player.id);
                return ListView.builder(
                  itemCount: moves.length,
                  itemBuilder: (context, index) {
                    final move = moves[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: player.color,
                          child: Text(
                            move.word[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(move.word),
                        subtitle: Text(
                          'Score: ${move.score} points',
                        ),
                        trailing: Text(
                          DateFormat.jm().format(move.timestamp),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}