import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/game_state_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/widgets/board_widget.dart';
import 'package:provider/provider.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrabble AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Show move history
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildScoreBoard(context),
          const Expanded(child: BoardWidget()),
          _buildControlBar(context),
        ],
      ),
    );
  }

  Widget _buildScoreBoard(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPlayerScore("Player 1", gameState.currentPlayerScore, true),
              _buildPlayerScore("Player 2", gameState.opponentScore, false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerScore(String player, int score, bool isCurrentPlayer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentPlayer ? Colors.blue[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            player,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            score.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Simulate Move'),
            onPressed: () {
              context.read<GameStateProvider>().simulateNewMove();
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Capture Board'),
            onPressed: () {
              // TODO: Implement camera functionality
            },
          ),
        ],
      ),
    );
  }
}