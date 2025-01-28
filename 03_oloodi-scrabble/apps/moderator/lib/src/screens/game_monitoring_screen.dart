// lib/src/screens/game_monitoring_screen.dart
import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_moderator_app/src/services/qr_service.dart';
import 'package:provider/provider.dart';
import '../providers/game_session_provider.dart';
import '../widgets/board_preview_widget.dart';
import '../widgets/move_history_widget.dart';
import '../widgets/player_info_widget.dart';
import 'move_capture_screen.dart';

class GameMonitoringScreen extends StatelessWidget {
  const GameMonitoringScreen({super.key});

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
            icon: const Icon(Icons.camera_alt),
            onPressed: () => _captureMove(context),
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () => _endGame(context),
          ),
        ],
      ),
      body: Consumer<GameSessionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.currentSession == null) {
            return const Center(child: Text('No active session'));
          }

          return Column(
            children: [
              // Player information
              PlayerInfoWidget(
                player1Name: provider.currentSession!.player1Name,
                player2Name: provider.currentSession!.player2Name,
              ),
              
              // Board preview
              const Expanded(
                flex: 2,
                child: BoardPreviewWidget(),
              ),
              
              // Move history
              const Expanded(
                flex: 1,
                child: MoveHistoryWidget(),
              ),
            ],
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

  void _showQRCode(BuildContext context) {
    final session = context.read<GameSessionProvider>().currentSession;
    if (session == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRDisplayScreen(sessionId: session.id),
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

    if (confirmed != true) return;

    if (!context.mounted) return;

    try {
      await context.read<GameSessionProvider>().endCurrentSession();
      if (!context.mounted) return;
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to end game: $e')),
      );
    }
  }
}