import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:oloodi_scrabble_moderator_app/src/services/score_calculator.dart';
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
    if (_processing ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return;
    }

    setState(() => _processing = true);

    try {
      // Clean up previous temp image if exists
      await _cleanupTempImage();

      // Show capturing status
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Capturing image...'),
              duration: Duration(seconds: 1)),
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
          const SnackBar(
              content: Text('Analyzing board...'),
              duration: Duration(seconds: 2)),
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
        final result = await _showMoveConfirmation(
          context,
          word,
          score,
          tiles,
        );

        if (result != null && mounted) {
          // Add move to session
          await gameState.addMove(
            word: result['word'],
            score: result['score'],
            playerId: session.currentPlayerId,
            tiles: List<Map<String, dynamic>>.from(result['tiles']),
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

  Future<Map<String, dynamic>?> _showMoveConfirmation(
    BuildContext context,
    String word,
    int score,
    List<Map<String, dynamic>> tiles,
  ) {
    final originalTiles = List<Map<String, dynamic>>.from(tiles);
    List<Map<String, dynamic>> editableTiles = List.from(tiles);
    bool hasBeenEdited = false;

    // Determine word orientation from tiles
    bool isHorizontal = tiles.length > 1
        ? tiles[0]['row'] == tiles[1]['row']
        : true; // Default to horizontal for single letter

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Confirm Move: $word'),
                  Text(
                    'Score: $score points',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Word Editor
                    TextField(
                      controller: TextEditingController(text: word),
                      decoration: const InputDecoration(
                        labelText: 'Word',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          word = value.toUpperCase();
                          hasBeenEdited = true;
                        });
                      },
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 16),

                    // Starting position editor
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: tiles.first['row'].toString(),
                            decoration: const InputDecoration(
                              labelText: 'Starting Row',
                              helperText: 'Range: 0-14',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final newRow = int.tryParse(value);
                              if (newRow != null &&
                                  newRow >= 0 &&
                                  newRow < 15) {
                                setState(() {
                                  hasBeenEdited = true;
                                  _recalculatePositions(
                                    editableTiles,
                                    startRow: newRow,
                                    startCol: editableTiles.first['col'],
                                    isHorizontal: isHorizontal,
                                  );
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: tiles.first['col'].toString(),
                            decoration: const InputDecoration(
                              labelText: 'Starting Column',
                              helperText: 'Range: 0-14',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final newCol = int.tryParse(value);
                              if (newCol != null &&
                                  newCol >= 0 &&
                                  newCol < 15) {
                                setState(() {
                                  hasBeenEdited = true;
                                  _recalculatePositions(
                                    editableTiles,
                                    startRow: editableTiles.first['row'],
                                    startCol: newCol,
                                    isHorizontal: isHorizontal,
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Orientation toggle
                    Row(
                      children: [
                        const Text('Orientation:'),
                        const SizedBox(width: 16),
                        ToggleButtons(
                          isSelected: [isHorizontal, !isHorizontal],
                          onPressed: (index) {
                            final newIsHorizontal = index == 0;
                            if (newIsHorizontal != isHorizontal) {
                              setState(() {
                                isHorizontal = newIsHorizontal;
                                hasBeenEdited = true;
                                _recalculatePositions(
                                  editableTiles,
                                  startRow: editableTiles.first['row'],
                                  startCol: editableTiles.first['col'],
                                  isHorizontal: newIsHorizontal,
                                );
                              });
                            }
                          },
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Horizontal'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Vertical'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tiles editor with Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tile Positions:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Tile'),
                          onPressed: () {
                            // Create a new tile at the end of the word
                            final newTile = Map<String, dynamic>.from({
                              'letter': 'A',
                              'points': 1,
                              'row': editableTiles.isEmpty
                                  ? 7
                                  : editableTiles.last['row'],
                              'col': editableTiles.isEmpty
                                  ? 7
                                  : editableTiles.last['col'] + 1,
                            });

                            setState(() {
                              editableTiles.add(newTile);
                              hasBeenEdited = true;
                              // Recalculate positions after adding new tile
                              _recalculatePositions(
                                editableTiles,
                                startRow: editableTiles.first['row'],
                                startCol: editableTiles.first['col'],
                                isHorizontal: isHorizontal,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (editableTiles.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'No tiles added yet. Click "Add Tile" to begin.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      ...editableTiles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final tile = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                tile['letter'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                                '${tile['letter']}: Points ${tile['points']}'),
                            subtitle: Text(
                              'Row ${tile['row']}, Col ${tile['col']}',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showTileEditor(
                                    context,
                                    tile,
                                    (updatedTile) {
                                      setState(() {
                                        editableTiles[index] = updatedTile;
                                        hasBeenEdited = true;
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () {
                                    setState(() {
                                      editableTiles.removeAt(index);
                                      hasBeenEdited = true;
                                      if (editableTiles.isNotEmpty) {
                                        // Recalculate positions after removing tile
                                        _recalculatePositions(
                                          editableTiles,
                                          startRow: editableTiles.first['row'],
                                          startCol: editableTiles.first['col'],
                                          isHorizontal: isHorizontal,
                                        );
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                    if (hasBeenEdited) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Manual corrections have been made',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Retake'),
                ),
                TextButton(
                  onPressed: () {
                    // Recalculate score based on updated tiles if needed
                    int updatedScore = score;
                    if (hasBeenEdited) {
                      updatedScore = ScoreCalculator.calculateScore(
                        editableTiles,
                        isFirstMove: word.length == editableTiles.length,
                      );
                    }

                    // Return a map containing all the updated information
                    Navigator.pop(context, {
                      'confirmed': true,
                      'word': word,
                      'score': updatedScore,
                      'tiles': editableTiles,
                      'hasBeenEdited': hasBeenEdited
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Helper method to recalculate positions (preserved from original implementation)
  void _recalculatePositions(
    List<Map<String, dynamic>> tiles, {
    required int startRow,
    required int startCol,
    required bool isHorizontal,
  }) {
    for (int i = 0; i < tiles.length; i++) {
      if (isHorizontal) {
        tiles[i]['row'] = startRow;
        tiles[i]['col'] = startCol + i;
      } else {
        tiles[i]['row'] = startRow + i;
        tiles[i]['col'] = startCol;
      }
    }
  }

// Enhanced tile editor dialog
  Future<void> _showTileEditor(
    BuildContext context,
    Map<String, dynamic> tile,
    Function(Map<String, dynamic>) onUpdate,
  ) {
    final letterController = TextEditingController(text: tile['letter']);
    final pointsController =
        TextEditingController(text: tile['points'].toString());

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Tile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: letterController,
                decoration: const InputDecoration(
                  labelText: 'Letter',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pointsController,
                decoration: const InputDecoration(
                  labelText: 'Points',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final points = int.tryParse(pointsController.text);
                if (letterController.text.isEmpty || points == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid values'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final updatedTile = Map<String, dynamic>.from(tile)
                  ..['letter'] = letterController.text.toUpperCase()
                  ..['points'] = points;

                onUpdate(updatedTile);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
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
