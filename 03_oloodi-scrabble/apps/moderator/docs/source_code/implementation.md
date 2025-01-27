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
import 'package:flutter/foundation.dart';

class GameSessionProvider with ChangeNotifier {
  // Game session state management will go here
}
```\n
\n### src/models/game_session.dart\n
```dart
class GameSession {
  final String id;
  final String player1Name;
  final String player2Name;
  final DateTime startTime;
  final String? qrCode;
  bool isActive;

  GameSession({
    required this.id,
    required this.player1Name,
    required this.player2Name,
    required this.startTime,
    this.qrCode,
    this.isActive = true,
  });
}
```\n
\n### src/screens/game_monitoring_screen.dart\n
```dart
import 'package:flutter/material.dart';

class GameMonitoringScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Monitoring'),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () => _captureMove(context),
          ),
        ],
      ),
      body: Column(
        children: [
          //_buildPlayerInfo(),
          //_buildBoardPreview(),
          //_buildMoveHistory(),
        ],
      ),
    );
  }

  Future<void> _captureMove(BuildContext context) async {
    // 1. Capture image
    // 2. Send to Gemini for analysis
    // 3. Show move confirmation dialog
    // 4. Update Firebase
  }
}
```\n
\n### src/screens/qr_display_screen.dart\n
```dart
```\n
\n### src/screens/move_capture_screen.dart\n
```dart
```\n
\n### src/screens/game_setup_screen.dart\n
```dart
import 'package:flutter/material.dart';

class GameSetupScreen extends StatefulWidget {
  @override
  _GameSetupScreenState createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  final _player1Controller = TextEditingController();
  final _player2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Game Setup')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _player1Controller,
              decoration: InputDecoration(labelText: 'Player 1 Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _player2Controller,
              decoration: InputDecoration(labelText: 'Player 2 Name'),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startGame,
              child: Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame() async {
    // Create game session in Firebase
    // Generate QR code
    // Navigate to game monitoring screen
  }
}```\n
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
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Firebase methods will go here
}
```\n
\n### src/services/gemini_service.dart\n
```dart
class GeminiService {
  // Gemini API integration will go here
}
```\n
\n### src/services/qr_service.dart\n
```dart
class QRService {
  // QR code generation methods will go here
}
```\n
\n### src/widgets/board_preview_widget.dart\n
```dart
```\n
\n### src/widgets/move_history_widget.dart\n
```dart
```\n
\n### src/widgets/player_info_widget.dart\n
```dart
```\n
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
