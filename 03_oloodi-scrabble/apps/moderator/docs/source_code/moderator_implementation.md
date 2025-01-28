# Source Code Documentation
\n## Project Structure\n
\n### main.dart\n
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/game_session_provider.dart';
import 'src/screens/game_setup_screen.dart';
import 'src/themes/app_theme.dart';

void main() {
  runApp(const ModeratorApp());
}

class ModeratorApp extends StatelessWidget {
  const ModeratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameSessionProvider()),
      ],
      child: MaterialApp(
        title: 'Scrabble Moderator',
        theme: AppTheme.theme,
        home:  GameSetupScreen(),
      ),
    );
  }
}
```\n
\n### src/providers/game_session_provider.dart\n
```dart
// lib/src/providers/game_session_provider.dart
import 'package:flutter/foundation.dart';
import 'package:oloodi_scrabble_moderator_app/src/models/game_session.dart';
import 'package:oloodi_scrabble_moderator_app/src/services/firebase_service.dart';
import 'package:oloodi_scrabble_moderator_app/src/services/qr_service.dart';

class GameSessionProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final QRService _qrService = QRService();

  GameSession? _currentSession;
  bool _isLoading = false;
  String? _error;

  // Getters
  GameSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveSession =>
      _currentSession != null && _currentSession!.isActive;

  // Create new game session
  Future<void> createGameSession(String player1Name, String player2Name) async {
    try {
      _setLoading(true);
      _clearError();

      // Create session in Firebase
      final session = await _firebaseService.createGameSession(
        player1Name: player1Name,
        player2Name: player2Name,
      );

      // Generate QR code data string
      final qrCodeData = _qrService.generateQRCodeData(session.id);

      // Update session with QR code data
      _currentSession = await _firebaseService.updateSessionQRCode(
        session.id,
        qrCodeData,
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to create game session: $e');
    } finally {
      _setLoading(false);
    }
  }

  // End current session
  Future<void> endCurrentSession() async {
    if (_currentSession == null) return;

    try {
      _setLoading(true);
      _clearError();

      await _firebaseService.updateSessionStatus(
        _currentSession!.id,
        false,
      );

      _currentSession = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to end session: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add move to current session
  Future<void> addMove({
    required String word,
    required int score,
    required String playerId,
    required List<Map<String, dynamic>> tiles,
  }) async {
    if (_currentSession == null) {
      _setError('No active session');
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      await _firebaseService.addMoveToSession(
        sessionId: _currentSession!.id,
        word: word,
        score: score,
        playerId: playerId,
        tiles: tiles,
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to add move: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load existing session
  Future<void> loadSession(String sessionId) async {
    try {
      _setLoading(true);
      _clearError();

      _currentSession = await _firebaseService.getSession(sessionId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load session: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
```\n
\n### src/models/game_session.dart\n
```dart
// lib/src/models/game_session.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class GameSession {
  final String id;
  final String player1Name;
  final String player2Name;
  final DateTime startTime;
  final String? qrCode;
  final String currentPlayerId;  // Added this field
  bool isActive;

  GameSession({
    required this.id,
    required this.player1Name,
    required this.player2Name,
    required this.startTime,
    this.qrCode,
    this.currentPlayerId = 'p1',  // Default to player 1
    this.isActive = true,
  });

  // Optional: Add a factory constructor to create from Firebase data
  factory GameSession.fromMap(Map<String, dynamic> data) {
    return GameSession(
      id: data['id'],
      player1Name: data['player1Name'],
      player2Name: data['player2Name'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      qrCode: data['qrCode'],
      currentPlayerId: data['currentPlayerId'] ?? 'p1',
      isActive: data['isActive'] ?? true,
    );
  }

  // Optional: Add a method to convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'player1Name': player1Name,
      'player2Name': player2Name,
      'startTime': startTime,
      'qrCode': qrCode,
      'currentPlayerId': currentPlayerId,
      'isActive': isActive,
    };
  }

  // Helper method to get the next player's ID
  String getNextPlayerId() {
    return currentPlayerId == 'p1' ? 'p2' : 'p1';
  }
}```\n
\n### src/screens/game_monitoring_screen.dart\n
```dart
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
}```\n
\n### src/screens/qr_display_screen.dart\n
```dart
```\n
\n### src/screens/move_capture_screen.dart\n
```dart
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
}```\n
\n### src/screens/game_setup_screen.dart\n
```dart
// lib/src/screens/game_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_session_provider.dart';
import 'game_monitoring_screen.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _player1Controller = TextEditingController();
  final _player2Controller = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Game Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _player1Controller,
                decoration: const InputDecoration(
                  labelText: 'Player 1 Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter player 1 name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _player2Controller,
                decoration: const InputDecoration(
                  labelText: 'Player 2 Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter player 2 name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isProcessing ? null : _startGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator()
                    : const Text('Start Game'),
              ),
              if (context.select((GameSessionProvider p) => p.error) != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    context.read<GameSessionProvider>().error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startGame() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      await context.read<GameSessionProvider>().createGameSession(
            _player1Controller.text.trim(),
            _player2Controller.text.trim(),
          );

      if (!mounted) return;

      // Navigate to monitoring screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GameMonitoringScreen(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
```\n
\n### src/themes/app_theme.dart\n
```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
    // Theme configuration will go here
  );
}
```\n
\n### src/services/firebase_service.dart\n
```dart
// lib/src/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/game_session.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Update session QR code
  Future<GameSession> updateSessionQRCode(
    String sessionId,
    String qrCode,
  ) async {
    await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .update({'qrCode': qrCode});

    final doc =
        await _firestore.collection('game_sessions').doc(sessionId).get();

    return _parseSessionDoc(doc);
  }

  // Update session status
  Future<void> updateSessionStatus(
    String sessionId,
    bool isActive,
  ) async {
    await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .update({'isActive': isActive});
  }

  // Get session by ID
  Future<GameSession> getSession(String sessionId) async {
    final doc =
        await _firestore.collection('game_sessions').doc(sessionId).get();

    if (!doc.exists) {
      throw Exception('Session not found');
    }

    return _parseSessionDoc(doc);
  }

  // Get active sessions
  Stream<List<GameSession>> getActiveSessions() {
    return _firestore
        .collection('game_sessions')
        .where('isActive', isEqualTo: true)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _parseSessionDoc(doc)).toList();
    });
  }

  // Parse Firestore document to GameSession
  GameSession _parseSessionDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['startTime'] as Timestamp;

    return GameSession(
      id: doc.id,
      player1Name: data['player1Name'],
      player2Name: data['player2Name'],
      startTime: timestamp.toDate(),
      qrCode: data['qrCode'],
      isActive: data['isActive'] ?? false,
    );
  }

// Get real-time board state updates
  Stream<Map<String, dynamic>> getBoardState(String sessionId) {
    return _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .collection('board_state')
        .doc('current')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return {};
      }
      return snapshot.data() as Map<String, dynamic>;
    });
  }

  // Get real-time session moves
  Stream<List<Map<String, dynamic>>> getSessionMoves(String sessionId) {
    return _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .collection('moves')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Convert Timestamp to DateTime
        if (data['timestamp'] is Timestamp) {
          data['timestamp'] = (data['timestamp'] as Timestamp).toDate();
        }
        return data;
      }).toList();
    });
  }

  // Get real-time player score
  Stream<int> getPlayerScore(String sessionId, String playerId) {
    return _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .collection('moves')
        .where('playerId', isEqualTo: playerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.fold<int>(
        0,
        (sum, doc) => sum + (doc.data()['score'] as int? ?? 0),
      );
    });
  }

  // Update board state
  Future<void> updateBoardState(
      String sessionId, Map<String, dynamic> boardState) async {
    await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .collection('board_state')
        .doc('current')
        .set(boardState, SetOptions(merge: true));
  }

  // Update player score (if needed separately from moves)
  Future<void> updatePlayerScore(
      String sessionId, String playerId, int score) async {
    await _firestore.collection('game_sessions').doc(sessionId).update({
      'scores.$playerId': FieldValue.increment(score),
    });
  }

  // Get single move by ID
  Future<Map<String, dynamic>?> getMove(String sessionId, String moveId) async {
    final doc = await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .collection('moves')
        .doc(moveId)
        .get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    if (data['timestamp'] is Timestamp) {
      data['timestamp'] = (data['timestamp'] as Timestamp).toDate();
    }
    return data;
  }

  // Switch to next player's turn
  Future<void> switchTurn(String sessionId) async {
    final session = await getSession(sessionId);
    final nextPlayerId = session.getNextPlayerId();

    await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .update({'currentPlayerId': nextPlayerId});
  }

  // Update your createGameSession method to include currentPlayerId
  Future<GameSession> createGameSession({
    required String player1Name,
    required String player2Name,
  }) async {
    final sessionId = _uuid.v4();
    final sessionData = {
      'id': sessionId,
      'player1Name': player1Name,
      'player2Name': player2Name,
      'startTime': FieldValue.serverTimestamp(),
      'isActive': true,
      'currentPlayerId': 'p1', // Start with player 1
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .set(sessionData);

    return GameSession(
      id: sessionId,
      player1Name: player1Name,
      player2Name: player2Name,
      startTime: DateTime.now(),
      currentPlayerId: 'p1',
      isActive: true,
    );
  }

  // Update your addMoveToSession method to handle turn switching
  Future<void> addMoveToSession({
    required String sessionId,
    required String word,
    required int score,
    required String playerId,
    required List<Map<String, dynamic>> tiles,
  }) async {
    final batch = _firestore.batch();

    // Add the move
    final moveRef = _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .collection('moves')
        .doc();

    batch.set(moveRef, {
      'word': word,
      'score': score,
      'playerId': playerId,
      'tiles': tiles,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Switch to next player
    final sessionRef = _firestore.collection('game_sessions').doc(sessionId);

    final session = await getSession(sessionId);
    batch.update(sessionRef, {
      'currentPlayerId': session.getNextPlayerId(),
    });

    await batch.commit();
  }
}
```\n
\n### src/services/gemini_service.dart\n
```dart
class GeminiService {
  analyzeBoardImage(String path) {}
  // Gemini API integration will go here
}
```\n
\n### src/services/qr_service.dart\n
```dart
// lib/src/services/qr_service.dart
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

class QRService {
  // Generate QR code data
  String generateQRCodeData(String sessionId) {
    final data = {
      'sessionId': sessionId,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'scrabble_game',
    };
    
    return jsonEncode(data);
  }

  // Generate QR code widget
  Widget generateQRCode(String sessionId, {double size = 200}) {
    final data = generateQRCodeData(sessionId);
    
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
    );
  }
}

// lib/src/screens/qr_display_screen.dart
class QRDisplayScreen extends StatelessWidget {
  final String sessionId;
  final QRService _qrService = QRService();

  QRDisplayScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _qrService.generateQRCode(sessionId, size: 250),
                    const SizedBox(height: 16),
                    const Text(
                      'Scan this code with the Companion App',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Session ID: $sessionId',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}```\n
\n### src/widgets/board_preview_widget.dart\n
```dart
// lib/src/widgets/board_preview_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_session_provider.dart';
import '../services/firebase_service.dart';

class BoardPreviewWidget extends StatelessWidget {
  const BoardPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Consumer<GameSessionProvider>(
        builder: (context, provider, child) {
          return StreamBuilder<Map<String, dynamic>>(
            stream: FirebaseService().getBoardState(provider.currentSession!.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final boardState = snapshot.data!;
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 15,
                  childAspectRatio: 1,
                ),
                itemCount: 225, // 15x15 grid
                itemBuilder: (context, index) {
                  final row = index ~/ 15;
                  final col = index % 15;
                  return _buildSquare(context, boardState, row, col);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSquare(BuildContext context, Map<String, dynamic> boardState, int row, int col) {
    final squareData = boardState['$row-$col'] as Map<String, dynamic>?;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        color: _getSquareColor(squareData?['type'] ?? 'normal'),
      ),
      child: squareData?['letter'] != null
          ? _buildTile(context, squareData!)
          : _buildSquareContent(squareData?['type'] ?? 'normal'),
    );
  }

  Widget _buildTile(BuildContext context, Map<String, dynamic> tileData) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: const Color(0xFFF7D698),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              tileData['letter'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            right: 2,
            bottom: 1,
            child: Text(
              '${tileData['points']}',
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareContent(String type) {
    String label = '';
    switch (type) {
      case 'tripleWord':
        label = 'TW';
        break;
      case 'doubleWord':
        label = 'DW';
        break;
      case 'tripleLetter':
        label = 'TL';
        break;
      case 'doubleLetter':
        label = 'DL';
        break;
      case 'center':
        label = '★';
        break;
      default:
        return const SizedBox();
    }

    return Center(
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Color _getSquareColor(String type) {
    switch (type) {
      case 'tripleWord':
        return Colors.red[100]!;
      case 'doubleWord':
        return Colors.pink[50]!;
      case 'tripleLetter':
        return Colors.blue[100]!;
      case 'doubleLetter':
        return Colors.lightBlue[50]!;
      case 'center':
        return Colors.pink[50]!;
      default:
        return Colors.white;
    }
  }
}```\n
\n### src/widgets/move_history_widget.dart\n
```dart
// lib/src/widgets/move_history_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/game_session_provider.dart';
import '../services/firebase_service.dart';

class MoveHistoryWidget extends StatelessWidget {
  const MoveHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: const Text(
              'Move History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _buildMoveList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveList() {
    return Consumer<GameSessionProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirebaseService().getSessionMoves(provider.currentSession!.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final moves = snapshot.data!;
            if (moves.isEmpty) {
              return const Center(child: Text('No moves yet'));
            }

            return ListView.builder(
              itemCount: moves.length,
              itemBuilder: (context, index) {
                final move = moves[index];
                return _buildMoveItem(context, move, index + 1);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMoveItem(BuildContext context, Map<String, dynamic> move, int moveNumber) {
    final timestamp = move['timestamp'] as DateTime;
    final isPlayer1 = move['playerId'] == 'p1';
    final provider = context.read<GameSessionProvider>();
    final playerName = isPlayer1 
        ? provider.currentSession!.player1Name 
        : provider.currentSession!.player2Name;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isPlayer1 ? Colors.blue[300] : Colors.green[300],
        child: Text(
          move['word'][0],
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(move['word']),
      subtitle: Text('$playerName - ${move['score']} points'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '#$moveNumber',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            DateFormat.jm().format(timestamp),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () => _showMoveDetails(context, move),
    );
  }

  void _showMoveDetails(BuildContext context, Map<String, dynamic> move) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Move #${move['word']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: ${move['score']} points'),
            const SizedBox(height: 8),
            Text('Player: ${move['playerId'] == 'p1' ? 'Player 1' : 'Player 2'}'),
            const SizedBox(height: 8),
            Text('Time: ${DateFormat.jm().format(move['timestamp'] as DateTime)}'),
            if (move['tiles'] != null) ...[
              const SizedBox(height: 16),
              const Text('Tiles placed:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final tile in move['tiles'])
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}```\n
\n### src/widgets/player_info_widget.dart\n
```dart
// lib/src/widgets/player_info_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_session_provider.dart';
import '../services/firebase_service.dart';

class PlayerInfoWidget extends StatelessWidget {
  final String player1Name;
  final String player2Name;

  const PlayerInfoWidget({
    super.key,
    required this.player1Name,
    required this.player2Name,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildPlayerInfo(
                context,
                name: player1Name,
                playerId: 'p1',
                color: Colors.blue[300]!,
              ),
            ),
            Container(
              height: 40,
              width: 2,
              color: Colors.grey[300],
            ),
            Expanded(
              child: _buildPlayerInfo(
                context,
                name: player2Name,
                playerId: 'p2',
                color: Colors.green[300]!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(
    BuildContext context, {
    required String name,
    required String playerId,
    required Color color,
  }) {
    return StreamBuilder<int>(
      stream: FirebaseService().getPlayerScore(
        context.read<GameSessionProvider>().currentSession!.id,
        playerId,
      ),
      builder: (context, snapshot) {
        final score = snapshot.data ?? 0;
        final isCurrentPlayer = context.select(
          (GameSessionProvider p) => p.currentSession?.currentPlayerId == playerId,
        );

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isCurrentPlayer
                ? Border.all(color: color, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: color,
                    radius: 16,
                    child: Text(
                      name[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Score: $score',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (isCurrentPlayer) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Current Turn',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}```\n
\n### src/widgets/camera_overlay_widget.dart\n
```dart
```\n
\n## pubspec.yaml\n
```yaml
name: oloodi_scrabble_moderator_app
description: Moderator app for Scrabble game management.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  provider: ^6.1.1
  firebase_core: ^2.24.2
  cloud_firestore: ^4.13.6
  google_generative_ai: ^0.2.0
  camera: ^0.10.5+9
  qr_flutter: ^4.1.0
  path_provider: ^2.1.2
  uuid: ^4.3.3
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```
