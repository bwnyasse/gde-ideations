import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/move.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/game_state_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/widgets/board_widget.dart';
import 'package:oloodi_scrabble_end_user_app/src/widgets/player_score_card.dart';
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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GameStateProvider>().restartGame();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildGameInfo(context),
          _buildScoreBoard(context),
          const Expanded(child: BoardWidget()),
          _buildControlBar(context),
        ],
      ),
    );
  }

  Widget _buildGameInfo(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining Letters: ${gameState.remainingLetters}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (gameState.isGameOver)
                const Text(
                  'Game Over!',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        );
      },
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
              for (final player in gameState.players)
                PlayerScoreCard(
                  player: player,
                  score: gameState.getPlayerScore(player.id),
                  isCurrentPlayer: player.id == gameState.currentPlayerId,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlBar(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Simulate Move'),
                onPressed: gameState.isGameOver
                    ? null  // Disable button when game is over
                    : () => gameState.simulateNextMove(),
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
      },
    );
  }
}