// lib/src/screens/move_capture_screen.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_session_provider.dart';
import '../services/gemini_service.dart';

class MoveCaptureScreen extends StatefulWidget {
  const MoveCaptureScreen({super.key});

  @override
  State<MoveCaptureScreen> createState() => _MoveCaptureScreenState();
}

class _MoveCaptureScreenState extends State<MoveCaptureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final GeminiService _geminiService = GeminiService();
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Move'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Camera preview
                      CameraPreview(_controller),
                      
                      // Overlay guide
                      CustomPaint(
                        size: Size.infinite,
                        painter: BoardOverlayPainter(),
                      ),
                      
                      // Processing indicator
                      if (_processing)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
                
                // Capture instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black87,
                  child: const Text(
                    'Position the board within the guide and ensure good lighting',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _processing ? null : _captureAndAnalyze,
        child: const Icon(Icons.camera),
      ),
    );
  }

  Future<void> _captureAndAnalyze() async {
    try {
      setState(() => _processing = true);

      // Capture image
      final image = await _controller.takePicture();

      // Analyze with Gemini
      final analysis = await _geminiService.analyzeBoardImage(image.path);

      if (!mounted) return;

      if (analysis['status'] == 'success') {
        // Show confirmation dialog
        final confirmed = await _showMoveConfirmation(analysis['data']);
        if (confirmed && mounted) {
          // Add move to session
          await context.read<GameSessionProvider>().addMove(
                word: analysis['data']['word'],
                score: analysis['data']['score'],
                playerId: context.read<GameSessionProvider>().currentSession!.currentPlayerId,
                tiles: analysis['data']['tiles'],
              );
          
          if (mounted) {
            Navigator.pop(context);
          }
        }
      } else {
        throw Exception(analysis['message']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  Future<bool> _showMoveConfirmation(Map<String, dynamic> moveData) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Move'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Word: ${moveData['word']}'),
            Text('Score: ${moveData['score']} points'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Retake'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }
}

class BoardOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw guide rectangle
    final rect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.1,
      size.width * 0.8,
      size.width * 0.8,
    );
    canvas.drawRect(rect, paint);

    // Draw corner markers
    final cornerLength = size.width * 0.05;
    final corners = [
      [rect.topLeft, Offset(rect.left + cornerLength, rect.top), Offset(rect.left, rect.top + cornerLength)],
      [rect.topRight, Offset(rect.right - cornerLength, rect.top), Offset(rect.right, rect.top + cornerLength)],
      [rect.bottomLeft, Offset(rect.left + cornerLength, rect.bottom), Offset(rect.left, rect.bottom - cornerLength)],
      [rect.bottomRight, Offset(rect.right - cornerLength, rect.bottom), Offset(rect.right, rect.bottom - cornerLength)],
    ];

    for (final corner in corners) {
      canvas.drawLine(corner[0], corner[1], paint);
      canvas.drawLine(corner[0], corner[2], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}