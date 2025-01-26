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
              for (final player in gameState.players)
                PlayerScoreCard(
                  player: player,
                  score: gameState.getPlayerScore(player.id),
                  isCurrentPlayer: player.id == 'p1', // Update based on current player
                ),
            ],
          ),
        );
      },
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
              final gameState = context.read<GameStateProvider>();
              final move = Move(
                word: "QUIZ",
                score: 22,
                playerId: 'p1',
                timestamp: DateTime.now(),
                tiles: [
                  PlacedTile(letter: "Q", row: 5, col: 5, points: 10),
                  PlacedTile(letter: "U", row: 5, col: 6, points: 1),
                  PlacedTile(letter: "I", row: 5, col: 7, points: 1),
                  PlacedTile(letter: "Z", row: 5, col: 8, points: 10),
                ],
              );
              gameState.addMove(move);
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