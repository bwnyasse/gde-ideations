import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/move_explanation.dart';

class MoveExplanationControls extends StatefulWidget {
  final MoveExplanation explanation;
  final VoidCallback onClose;

  const MoveExplanationControls({
    super.key,
    required this.explanation,
    required this.onClose,
  });

  @override
  State<MoveExplanationControls> createState() =>
      _MoveExplanationControlsState();
}

class _MoveExplanationControlsState extends State<MoveExplanationControls> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  Future<void> _playPause() async {
    if (widget.explanation.audioData == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_position == Duration.zero) {
        await _audioPlayer.play(
            BytesSource(Uint8List.fromList(widget.explanation.audioData!)));
      } else {
        await _audioPlayer.resume();
      }
    }

    setState(() => _isPlaying = !_isPlaying);
  }

  Future<void> _seekTo(Duration position) async {
    await _audioPlayer.seek(position);
    setState(() => _position = position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.tertiary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  color: theme.colorScheme.tertiary,
                  size: 32,
                ),
                onPressed: _playPause,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Move Explanation',
                      style: TextStyle(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: TextStyle(
                            color:
                                theme.colorScheme.onPrimary.withOpacity(0.70),
                            fontSize: 12,
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                              activeTrackColor: theme.colorScheme.tertiary,
                              inactiveTrackColor:
                                  theme.colorScheme.onPrimary.withOpacity(0.24),
                              thumbColor: theme.colorScheme.tertiary,
                              overlayColor:
                                  theme.colorScheme.tertiary.withOpacity(0.2),
                            ),
                            child: Slider(
                              min: 0,
                              max: _duration.inMilliseconds.toDouble(),
                              value: _position.inMilliseconds.toDouble(),
                              onChanged: (value) {
                                _seekTo(Duration(milliseconds: value.toInt()));
                              },
                            ),
                          ),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: TextStyle(
                            color:
                                theme.colorScheme.onPrimary.withOpacity(0.70),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _audioPlayer.stop();
                    widget.onClose();
                  },
                  color: theme.colorScheme.onPrimary.withOpacity(0.70)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.explanation.text,
            style:
                TextStyle(color: theme.colorScheme.onPrimary.withOpacity(0.70)),
          ),
        ],
      ),
    );
  }
}
