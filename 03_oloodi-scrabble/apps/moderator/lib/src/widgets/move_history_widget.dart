// lib/src/widgets/move_history_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/game_session_provider.dart';
import '../services/firebase_service.dart';

class MoveHistoryWidget extends StatelessWidget {
  const MoveHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: const Text(
              'Move History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _buildMoveList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveList() {
    return Consumer<GameSessionProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirebaseService().getSessionMoves(provider.currentSession!.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final moves = snapshot.data!;
            if (moves.isEmpty) {
              return const Center(child: Text('No moves yet'));
            }

            return ListView.builder(
              itemCount: moves.length,
              itemBuilder: (context, index) {
                final move = moves[index];
                return _buildMoveItem(context, move, index + 1);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMoveItem(BuildContext context, Map<String, dynamic> move, int moveNumber) {
    final timestamp = move['timestamp'] as DateTime;
    final isPlayer1 = move['playerId'] == 'p1';
    final provider = context.read<GameSessionProvider>();
    final playerName = isPlayer1 
        ? provider.currentSession!.player1Name 
        : provider.currentSession!.player2Name;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isPlayer1 ? Colors.blue[300] : Colors.green[300],
        child: Text(
          move['word'][0],
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(move['word']),
      subtitle: Text('$playerName - ${move['score']} points'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '#$moveNumber',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            DateFormat.jm().format(timestamp),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () => _showMoveDetails(context, move),
    );
  }

  void _showMoveDetails(BuildContext context, Map<String, dynamic> move) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Move #${move['word']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: ${move['score']} points'),
            const SizedBox(height: 8),
            Text('Player: ${move['playerId'] == 'p1' ? 'Player 1' : 'Player 2'}'),
            const SizedBox(height: 8),
            Text('Time: ${DateFormat.jm().format(move['timestamp'] as DateTime)}'),
            if (move['tiles'] != null) ...[
              const SizedBox(height: 16),
              const Text('Tiles placed:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final tile in move['tiles'])
                    Chip(
                      label: Text('${tile['letter']} (${tile['points']})'),
                    ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}