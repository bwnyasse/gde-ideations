// lib/src/screens/move_capture_screen.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/game_session_provider.dart';
import '../services/gemini_service.dart';

class MoveCaptureScreen extends StatefulWidget {
  const MoveCaptureScreen({super.key});

  @override
  State<MoveCaptureScreen> createState() => _MoveCaptureScreenState();
}

class _MoveCaptureScreenState extends State<MoveCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  String? _error;
  bool _processing = false;
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted) {
      _initializeCamera();
      return;
    }

    status = await Permission.camera.request();
    if (status.isGranted) {
      _initializeCamera();
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        setState(() {
          _error =
              'Camera permission was permanently denied. Please enable it in app settings.';
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _error =
              'Camera permission is required to capture moves. Please grant the permission.';
        });
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'No cameras available');
        return;
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.max,
        enableAudio: false,
      );

      await controller.initialize();

      if (mounted) {
        setState(() {
          _controller = controller;
          _isCameraInitialized = true;
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Error initializing camera: $e');
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_processing || _controller == null || !_controller!.value.isInitialized) {
      return;
    }

    setState(() => _processing = true);

    try {
      // Show processing indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing image...')),
      );

      // Capture image
      final image = await _controller!.takePicture();

      // Get current player ID
      final gameState = context.read<GameSessionProvider>();
      final currentPlayerId = gameState.currentSession?.currentPlayerId;

      if (currentPlayerId == null) {
        throw Exception('No active game session');
      }

      // Analyze with Gemini
      final analysis = await _geminiService.analyzeBoardImage(image.path);

      if (!mounted) return;

      // Close the processing snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (analysis['status'] == 'success') {
        // Show confirmation dialog
        final confirmed = await _showMoveConfirmation(analysis['data']);

        if (confirmed && mounted) {
          // Add move to session
          await context.read<GameSessionProvider>().addMove(
                word: analysis['data']['word'],
                score: analysis['data']['score'],
                playerId: currentPlayerId,
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
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
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
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Move'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Word: ${moveData['word']}'),
                const SizedBox(height: 8),
                Text('Score: ${moveData['score']} points'),
                if (moveData['tiles'] != null) ...[
                  const SizedBox(height: 16),
                  const Text('Tiles placed:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (var tile in moveData['tiles'])
                        Chip(
                          label: Text('${tile['letter']} (${tile['points']})'),
                        ),
                    ],
                  ),
                ],
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
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Move'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _requestCameraPermission,
                child: const Text('Grant Camera Permission'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('Open App Settings'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Preview
        CameraPreview(_controller!),

        // Capture Guide Overlay
        CustomPaint(
          painter: BoardOverlayPainter(),
        ),

        // Processing Indicator
        if (_processing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),

        // Capture Button
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton(
              onPressed: _processing ? null : _captureAndAnalyze,
              child: _processing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.camera_alt),
            ),
          ),
        ),

        // Instructions
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black54,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Position the board within the guide and ensure good lighting',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class BoardOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Calculate square size to maintain aspect ratio
    final squareSize = size.width < size.height ? size.width * 0.8 : size.height * 0.8;
    final left = (size.width - squareSize) / 2;
    final top = (size.height - squareSize) / 2;
    final rect = Rect.fromLTWH(left, top, squareSize, squareSize);

    // Draw the main rectangle
    canvas.drawRect(rect, paint);

    // Draw corner markers
    final cornerLength = squareSize * 0.1;
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