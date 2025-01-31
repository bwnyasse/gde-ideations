import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/move.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/game_state_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/widgets/board_widget.dart';
import 'package:oloodi_scrabble_end_user_app/src/widgets/left_menu.dart';
import 'package:oloodi_scrabble_end_user_app/src/widgets/settings_panel.dart';
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
  bool _showSettings = false;

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
    final theme = Theme.of(context);
    try {
      await gameState.handleMoveExplanation(theme.colorScheme.tertiary, move);
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

                  // Settings Button
                  Positioned(
                    right: 16,
                    top: 16,
                    child: _buildSettingsButton(),
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

                  // Settings Panel
                  if (_showSettings)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: SettingsPanel(
                        onClose: () => setState(() => _showSettings = false),
                      ),
                    ),

                  // Chat Overlay
                  if (_showChat) _buildChatOverlay(context),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSettingsButton() {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: 'Settings',
        child: InkWell(
          onTap: () => setState(() => _showSettings = !_showSettings),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _showSettings
                  ? theme.colorScheme.tertiary.withOpacity(0.1)
                  : theme.colorScheme.onBackground.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _showSettings
                    ? theme.colorScheme.tertiary
                    : theme.colorScheme.onPrimary.withOpacity(0.1),
              ),
            ),
            child: Icon(
              Icons.settings,
              color: _showSettings
                  ? theme.colorScheme.tertiary
                  : theme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatOverlay(context) {
    final theme = Theme.of(context);
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
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Game Assistant',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
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
