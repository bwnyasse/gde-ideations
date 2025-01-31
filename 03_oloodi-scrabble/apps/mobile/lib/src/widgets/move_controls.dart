// widgets/move_controls.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/game_state_provider.dart';
import 'package:provider/provider.dart';

class MoveControls extends StatefulWidget {
  const MoveControls({super.key});

  @override
  State<MoveControls> createState() => _MoveControlsState();
}

class _MoveControlsState extends State<MoveControls> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _handlePlayback(GameStateProvider gameState) async {
    final theme = Theme.of(context);
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
      return;
    }

    final lastMove = gameState.lastMove;
    if (lastMove == null) return;

    try {
      final explanation =
          await gameState.explainMove(theme.colorScheme.tertiary, lastMove);
      if (!mounted) return;

      if (explanation.audioData != null) {
        await _audioPlayer
            .play(BytesSource(Uint8List.fromList(explanation.audioData!)));
        setState(() => _isPlaying = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing explanation: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<GameStateProvider>(
      builder: (context, gameState, _) {
        final lastMove = gameState.lastMove;
        final isEnabled = lastMove != null;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.tertiary.withOpacity(0.3),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (lastMove != null) ...[
                Text(
                  'Last Move: ${lastMove.word}',
                  style: TextStyle(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.stop_circle : Icons.play_circle,
                    color: isEnabled ? theme.colorScheme.tertiary : Colors.grey,
                    size: 32,
                  ),
                  onPressed:
                      isEnabled ? () => _handlePlayback(gameState) : null,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
