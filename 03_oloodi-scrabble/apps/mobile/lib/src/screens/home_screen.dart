import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/move.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/game_state_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/themes/app_themes.dart';
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
  bool _showChat = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(3, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/app_icon.png', // Add your app icon
                        width: 32,
                        height: 32,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.sports_esports,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Oloodi Scrabble\nAI Companion',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24),

                // Player Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildPlayerCards(),
                ),

                const Spacer(),

                // Action Buttons
                _buildActionButtons(),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: Stack(
              children: [
                // Board
                const Center(
                  child: BoardWidget(),
                ),

                // Move History Panel
                if (_showHistory)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 300,
                    child: Card(
                      margin: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.horizontal(left: Radius.circular(12)),
                      ),
                      child: const MoveHistoryPanel(),
                    ),
                  ),

                // Chat Overlay
                if (_showChat) _buildChatOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCards() {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        return Column(
          children: [
            for (final player in gameState.players) ...[
              PlayerScoreCard(
                player: player,
                score: gameState.getPlayerScore(player.id),
                isCurrentPlayer: player.id == gameState.currentPlayerId,
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Divider(color: Colors.white24),
            _buildActionButton(
                icon: Icons.refresh,
                label: 'Refresh Board',
                onPressed: gameState.isGameOver
                    ? null
                    : () async {
                        try {
                          await gameState.updateBoard();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Board refreshed successfully'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error refreshing board: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }),
            _buildActionButton(
              icon: _showHistory ? Icons.history_toggle_off : Icons.history,
              label: 'Move History',
              isActive: _showHistory,
              onPressed: () {
                setState(() {
                  _showHistory = !_showHistory;
                });
              },
            ),
            _buildActionButton(
              icon: _showChat ? Icons.chat_bubble : Icons.chat_bubble_outline,
              label: 'Chat',
              isActive: _showChat,
              onPressed: () {
                setState(() {
                  _showChat = !_showChat;
                });
              },
            ),
            _buildActionButton(
              icon: Icons.lightbulb_outline,
              label: 'Explain Last Move',
              onPressed: gameState.lastMove != null
                  ? () => _showMoveExplanation(gameState.lastMove!)
                  : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: TextButton.icon(
        icon: Icon(
          icon,
          color: isActive ? AppTheme.accentColor : Colors.white,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.accentColor : Colors.white,
          ),
        ),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
      ),
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
