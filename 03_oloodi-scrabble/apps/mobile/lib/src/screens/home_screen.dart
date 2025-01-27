import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/game_state_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/widgets/board_widget.dart';
import 'package:oloodi_scrabble_end_user_app/src/widgets/player_score_card.dart';
import 'package:provider/provider.dart';

import '../widgets/move_history_panel.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrabble Companion'),
        actions: [
          IconButton(
            icon: Icon(_showHistory ? Icons.history_toggle_off : Icons.history),
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GameStateProvider>().restartGame();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Main game area
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate board size to fit the screen
                    final availableHeight = constraints.maxHeight;
                    final scoreHeight = 80.0; // Height for score cards
                    final controlHeight = 60.0; // Height for control bar
                    final boardSize = availableHeight - scoreHeight - controlHeight - 16.0; // 16.0 for padding

                    return Column(
                      children: [
                        // Player scores - fixed height
                        SizedBox(
                          height: scoreHeight,
                          child: _buildPlayerScores(context),
                        ),
                        
                        // Board - takes remaining space up to calculated board size
                        SizedBox(
                          height: boardSize,
                          width: boardSize,
                          child: const BoardWidget(),
                        ),
                        
                        // Control bar - fixed height
                        SizedBox(
                          height: controlHeight,
                          child: _buildControlBar(context),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Slide-in history panel
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _showHistory ? 300 : 0,
            child: _showHistory
                ? const MoveHistoryPanel()
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerScores(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final player in gameState.players)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: PlayerScoreCard(
                    player: player,
                    score: gameState.getPlayerScore(player.id),
                    isCurrentPlayer: player.id == gameState.currentPlayerId,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildControlBar(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        return Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Simulate Move'),
            onPressed: gameState.isGameOver
                ? null
                : () => gameState.simulateNextMove(),
          ),
        );
      },
    );
  }
}