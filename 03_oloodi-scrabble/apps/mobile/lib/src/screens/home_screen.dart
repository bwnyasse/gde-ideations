import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/move.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/game_state_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/themes/app_themes.dart';
import 'package:oloodi_scrabble_end_user_app/src/widgets/board_widget.dart';
import 'package:oloodi_scrabble_end_user_app/src/widgets/left_menu.dart';
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

  Future<void> _handleRefresh(GameStateProvider gameState) async {
    try {
      await gameState.updateBoard();
      if (mounted) {
        // TODO: Add a snow Snack Bar Message : Board refreshed successfully
      }
    } catch (e) {
      if (mounted) {
        // TODO: Add a snow Snack Bar Message : Error refreshing board
      }
    }
  }

  Future<void> _handleExplanationToggle(
      GameStateProvider gameState, Move move) async {
    try {
      await gameState.handleMoveExplanation(move);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameStateProvider>(builder: (context, gameState, _) {
        return Row(
          children: [
            ResponsiveLeftMenu(
              showHistory: _showHistory,
              showChat: _showChat,
              onHistoryToggle: (value) => setState(() => _showHistory = value),
              onChatToggle: (value) => setState(() => _showChat = value),
              onRefreshBoard: () => _handleRefresh(gameState),
              onExplanationToggle: (move) =>
                  _handleExplanationToggle(gameState, move),
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
                    const Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 300,
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(12)),
                        ),
                        child: MoveHistoryPanel(),
                      ),
                    ),

                  // Chat Overlay
                  if (_showChat) _buildChatOverlay(),
                ],
              ),
            ),
          ],
        );
      }),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.vertical(
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
                    onPressed: () => setState(() => _showChat = false),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text('Chat functionality coming soon...'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
