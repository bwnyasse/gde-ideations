import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/move.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/game_state_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/themes/app_themes.dart';
import 'package:oloodi_scrabble_end_user_app/src/widgets/board_widget.dart';
import 'package:oloodi_scrabble_end_user_app/src/widgets/player_score_card.dart';
import 'package:provider/provider.dart';

import '../widgets/move_history_panel.dart';

// lib/screens/home_screen.dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showHistory = false;
  bool _showChat = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrabble Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show game info/stats
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Main game area
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildPlayerScores(context),
                    const Expanded(child: BoardWidget()),
                  ],
                ),
                if (_showChat) _buildChatOverlay(),
              ],
            ),
          ),
          // Move history panel
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _showHistory ? 300 : 0,
            child: _showHistory ? const MoveHistoryPanel() : null,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
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

  Widget _buildBottomActionBar() {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        final lastMove = gameState.lastMove;

        return BottomAppBar(
          color: AppTheme.primaryColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // History toggle
                IconButton(
                  icon: Icon(
                    _showHistory ? Icons.history_toggle_off : Icons.history,
                    color: _showHistory ? AppTheme.accentColor : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _showHistory = !_showHistory;
                    });
                  },
                  tooltip: 'Move History',
                ),
                // Simulate move
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  onPressed: gameState.isGameOver
                      ? null
                      : () => gameState.simulateNextMove(),
                  tooltip: 'Simulate Move',
                ),
                // Chat toggle
                IconButton(
                  icon: Icon(
                    _showChat ? Icons.chat_bubble : Icons.chat_bubble_outline,
                    color: _showChat ? AppTheme.accentColor : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _showChat = !_showChat;
                    });
                  },
                  tooltip: 'Chat',
                ),
                // Explain last move
                IconButton(
                  icon:
                      const Icon(Icons.lightbulb_outline, color: Colors.white),
                  onPressed: lastMove != null
                      ? () => _showMoveExplanation(lastMove)
                      : null,
                  tooltip: 'Explain Last Move',
                ),
                // Restart game
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    gameState.restartGame();
                  },
                  tooltip: 'Restart Game',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatOverlay() {
    return Positioned(
      right: 16,
      bottom: 16,
      width: 300,
      height: 400,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Chat header
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Game Assistant',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _showChat = false;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Chat messages area
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text('Chat functionality coming soon...'),
                ),
              ),
            ),
            // Input area
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () {
                      // Implement voice input
                    },
                  ),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      // Send message
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoveExplanation(Move lastMove) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${lastMove.word} (${lastMove.score} points)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Player: ${lastMove.playerId}'),
            const SizedBox(height: 8),
            const Text('Explanation coming soon...'),
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
