// lib/src/screens/game_monitoring_screen.dart
import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_moderator_app/src/services/qr_service.dart';
import 'package:oloodi_scrabble_moderator_app/src/widgets/recognition_metrics_viewer.dart';
import 'package:provider/provider.dart';
import '../providers/game_session_provider.dart';
import '../widgets/move_history_widget.dart';
import '../widgets/player_info_widget.dart';
import 'move_capture_screen.dart';

class GameMonitoringScreen extends StatelessWidget {
  final String sessionId;

  const GameMonitoringScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () => _showQRCode(context),
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () => _endGame(context),
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => Dialog(
                child: SizedBox(
                  width: 400,
                  height: 600,
                  child: MetricsViewer(sessionId: sessionId),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: context.read<GameSessionProvider>().loadSession(sessionId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Consumer<GameSessionProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return Center(child: Text(provider.error!));
              }

              if (provider.currentSession == null) {
                return const Center(child: Text('Session not found'));
              }

              return Column(
                children: [
                  // Player information with selection handlers
                  PlayerInfoWidget(
                    player1Name: provider.currentSession!.player1Name,
                    player2Name: provider.currentSession!.player2Name,
                    onPlayer1Selected: () => _selectPlayer(context, 'p1'),
                    onPlayer2Selected: () => _selectPlayer(context, 'p2'),
                  ),

                  // Move history
                  const Expanded(
                    child: MoveHistoryWidget(),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _captureMove(context),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Capture Move'),
      ),
    );
  }

  Future<void> _selectPlayer(BuildContext context, String playerId) async {
    try {
      // Get the current session
      final provider = context.read<GameSessionProvider>();
      final session = provider.currentSession;

      if (session == null) {
        throw Exception('No active session');
      }

      // Only allow changing to a different player
      if (session.currentPlayerId != playerId) {
        // Update current player
        await provider.switchCurrentPlayer(playerId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Switched to ${playerId == 'p1' ? 'Player 1' : 'Player 2'}\'s turn'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error switching player: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showQRCode(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRDisplayScreen(sessionId: sessionId),
      ),
    );
  }

  void _captureMove(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MoveCaptureScreen(),
      ),
    );
  }

  Future<void> _endGame(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Game'),
        content: const Text('Are you sure you want to end this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End Game'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<GameSessionProvider>().endCurrentSession();
      if (!context.mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to end game: $e')),
      );
    }
  }
}
