import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:oloodi_scrabble_moderator_app/src/widgets/board_overlay_painter.dart';
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
  String? _currentImagePath; // Track the current image path

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
    _cleanupTempImage();
    super.dispose();
  }

  // Cleanup temporary image
  Future<void> _cleanupTempImage() async {
    if (_currentImagePath != null) {
      try {
        final file = File(_currentImagePath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error cleaning up temp image: $e');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (mounted) {
      if (status.isGranted) {
        _initializeCamera();
      } else {
        setState(() {
          _error = status.isPermanentlyDenied
              ? 'Camera permission permanently denied. Please enable it in settings.'
              : 'Camera permission is required to capture moves.';
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
      // Clean up previous temp image if exists
      await _cleanupTempImage();

      // Show capturing status
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Capturing image...'), duration: Duration(seconds: 1)),
        );
      }

      // Capture image
      final image = await _controller!.takePicture();
      
      // Crop image
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Adjust Board Position',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Adjust Board Position',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile == null) {
        throw Exception('Image cropping cancelled');
      }

      _currentImagePath = croppedFile.path;

      // Get current session details
      final gameState = context.read<GameSessionProvider>();
      final session = gameState.currentSession;
      
      if (session == null) {
        throw Exception('No active session');
      }

      // Show analyzing status
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analyzing board...'), duration: Duration(seconds: 2)),
        );
      }

      // Analyze with Gemini
      final analysis = await _geminiService.analyzeBoardImage(
        session.id,
        croppedFile.path,
      );

      if (!mounted) return;

      // Close any existing snackbars
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (analysis['status'] == 'success') {
        List<Map<String, dynamic>> tiles = [];
        String word = '';
        int score = 0;
        String? imagePath = analysis['imagePath'];

        print('Analysis response: $analysis'); // Debug log

        if (analysis['type'] == 'initial') {
          tiles = (analysis['data']['board'] as List)
              .map((tile) => {
                    'letter': tile['letter'],
                    'row': tile['row'],
                    'col': tile['col'],
                    'points': tile['points'],
                  })
              .toList();
              
          word = tiles.map((t) => t['letter']).join();
          score = tiles.fold(0, (sum, tile) => sum + (tile['points'] as int));
          
          await gameState.updateBoardState(session.id, tiles);
        } else {
          tiles = (analysis['data']['newLetters'] as List)
              .map((tile) => {
                    'letter': tile['letter'],
                    'row': tile['row'],
                    'col': tile['col'],
                    'points': tile['points'],
                  })
              .toList();
          
          word = analysis['data']['word'] as String;
          score = analysis['data']['score'] as int;
        }

        // Show confirmation dialog
        final confirmed = await _showMoveConfirmation(word, score, tiles);

        if (confirmed == true && mounted) {
          // Add move to session
          await gameState.addMove(
            word: word,
            score: score,
            playerId: session.currentPlayerId,
            tiles: tiles,
            imagePath: imagePath,
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

  Future<bool?> _showMoveConfirmation(
    String word,
    int score,
    List<Map<String, dynamic>> tiles,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Move'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Word: $word'),
            const SizedBox(height: 8),
            Text('Score: $score points'),
            if (tiles.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Tiles placed:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (var tile in tiles)
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
    );
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

        // Board Alignment Overlay
        CustomPaint(
          painter: BoardOverlayPainter(),
          child: Container(),
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

        // Instructions (moved up to avoid button overlap)
        Positioned(
          bottom: 100, // Increased bottom padding to move above the button
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black54,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: const Text(
              'Align the board within the square frame and ensure good lighting',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
