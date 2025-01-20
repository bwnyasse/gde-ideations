import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/game_state_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/service/camera_service.dart';
import 'package:oloodi_scrabble_end_user_app/src/service/gemini_service.dart';
import 'package:provider/provider.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraService _cameraService;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _cameraService = CameraService();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
    } catch (e) {
      // Handle initialization error
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      height: 300,
      child: Stack(
        children: [
          if (_cameraService.isInitialized)
            CameraPreview(_cameraService.controller!),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: _captureAndAnalyze,
                ),
                IconButton(
                  icon: const Icon(Icons.flip_camera_android,
                      color: Colors.white),
                  onPressed: () {
                    // Implement camera flip
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndAnalyze() async {
    try {
      final imagePath = await _cameraService.captureImage();
      final gameState = context.read<GameStateProvider>();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Analyze image using Gemini
      final geminiService = GeminiService();
      final analysis = await geminiService.analyzeBoardImage(imagePath);

      // Update game state with new board state
      if (analysis['status'] == 'success') {
        // Implementation needed: Update game state with analysis results
        // gameState.updateBoardFromAnalysis(analysis['data']);
      }

      // Close loading indicator
      Navigator.pop(context);
    } catch (e) {
      // Handle capture error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }
}
