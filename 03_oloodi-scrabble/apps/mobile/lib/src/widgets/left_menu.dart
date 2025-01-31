import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/move.dart';
import '../themes/app_themes.dart';
import '../widgets/player_score_card.dart';
import '../providers/game_state_provider.dart';

class ResponsiveLeftMenu extends StatelessWidget {
  final bool showHistory;
  final bool showChat;
  final Function(bool) onHistoryToggle;
  final Function(bool) onChatToggle;
  final Function() onRefreshBoard;
  final Function(Move) onExplanationToggle;

  const ResponsiveLeftMenu({
    super.key,
    required this.showHistory,
    required this.showChat,
    required this.onHistoryToggle,
    required this.onChatToggle,
    required this.onRefreshBoard,
    required this.onExplanationToggle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final menuWidth = math.min(screenWidth * 0.25, 350.0);

    return Container(
      width: menuWidth,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(3, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Players'),
                  const SizedBox(height: 16),
                  _buildPlayerCards(),
                ],
              ),
            ),
          ),
          _buildActionRow(context),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, _) {
        final lastMove = gameState.lastMove;
        final isPlaying = gameState.isPlaying;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.5),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionIcon(
                icon: Icons.refresh,
                label: 'Refresh',
                isEnabled: !gameState.isGameOver,
                onTap: onRefreshBoard,
              ),
              _buildActionIcon(
                icon: showHistory ? Icons.history_toggle_off : Icons.history,
                label: 'History',
                isActive: showHistory,
                onTap: () => onHistoryToggle(!showHistory),
              ),
              _buildActionIcon(
                icon: showChat ? Icons.chat_bubble : Icons.chat_bubble_outline,
                label: 'Chat',
                isActive: showChat,
                onTap: () => onChatToggle(!showChat),
              ),
              if (lastMove != null)
                _buildActionIcon(
                  icon: isPlaying
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outlined,
                  label: isPlaying ? 'Stop' : 'Play',
                  isActive: isPlaying,
                  onTap: () => onExplanationToggle(lastMove),
                )
              else
                _buildActionIcon(
                  icon: Icons.lightbulb_outline,
                  label: 'Explain',
                  isEnabled: false,
                  onTap: null,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required String label,
    bool isActive = false,
    bool isEnabled = true,
    VoidCallback? onTap,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accentColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? AppTheme.accentColor : Colors.transparent,
            ),
          ),
          child: Icon(
            icon,
            color: !isEnabled
                ? Colors.white.withOpacity(0.3)
                : isActive
                    ? AppTheme.accentColor
                    : Colors.white.withOpacity(0.7),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sports_esports,
              color: AppTheme.accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oloodi Scrabble',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                Text(
                  'AI Companion',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withOpacity(0.6),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
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
              const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }
}
