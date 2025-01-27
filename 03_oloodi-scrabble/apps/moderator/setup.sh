#!/bin/bash

# Create Scrabble Moderator App
echo "Creating Scrabble Moderator App structure..."

# Create project using Flutter
flutter create \
  --org com.oloodi \
  --project-name oloodi_scrabble_moderator_app \
  --platforms=ios,android \
  .

# Create main app directory structure
mkdir -p lib/src/{models,screens,services,widgets,themes,providers}

# Create model files
echo "Creating model files..."
cat > lib/src/models/game_session.dart << 'EOL'
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
EOL

# Create screens
echo "Creating screen files..."
mkdir -p lib/src/screens
touch lib/src/screens/game_setup_screen.dart
touch lib/src/screens/game_monitoring_screen.dart
touch lib/src/screens/move_capture_screen.dart
touch lib/src/screens/qr_display_screen.dart

# Create services
echo "Creating service files..."
cat > lib/src/services/firebase_service.dart << 'EOL'
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Firebase methods will go here
}
EOL

cat > lib/src/services/gemini_service.dart << 'EOL'
class GeminiService {
  // Gemini API integration will go here
}
EOL

cat > lib/src/services/qr_service.dart << 'EOL'
class QRService {
  // QR code generation methods will go here
}
EOL

# Create widgets
echo "Creating widget files..."
mkdir -p lib/src/widgets
touch lib/src/widgets/board_preview_widget.dart
touch lib/src/widgets/player_info_widget.dart
touch lib/src/widgets/move_history_widget.dart
touch lib/src/widgets/camera_overlay_widget.dart

# Create providers
echo "Creating provider files..."
cat > lib/src/providers/game_session_provider.dart << 'EOL'
import 'package:flutter/foundation.dart';

class GameSessionProvider with ChangeNotifier {
  // Game session state management will go here
}
EOL

# Create theme
echo "Creating theme file..."
cat > lib/src/themes/app_theme.dart << 'EOL'
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
    // Theme configuration will go here
  );
}
EOL

# Update main.dart
echo "Creating main.dart..."
cat > lib/main.dart << 'EOL'
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
        home: const GameSetupScreen(),
      ),
    );
  }
}
EOL

# Create assets directories
echo "Creating asset directories..."
mkdir -p assets/{images,icons}

# Update pubspec.yaml with dependencies
echo "Updating pubspec.yaml..."
cat > pubspec.yaml << 'EOL'
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
EOL

# Create .gitignore
echo "Creating .gitignore..."
cat > .gitignore << 'EOL'
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# Visual Studio Code related
.classpath
.project
.settings/
.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Web related
lib/generated_plugin_registrant.dart

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release

# iOS/XCode related
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/*sync/
**/ios/**/.sconsign.dblite
**/ios/**/.tags*
**/ios/**/.vagrant/
**/ios/**/DerivedData/
**/ios/**/Icon?
**/ios/**/Pods/
**/ios/**/.symlinks/
**/ios/**/profile
**/ios/**/xcuserdata
**/ios/.generated/
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# Firebase configuration files
google-services.json
GoogleService-Info.plist
EOL

# Make the project ready for development
echo "Running flutter pub get..."
flutter pub get

echo "Project structure created successfully!"
echo "Next steps:"
echo "1. Add your Firebase configuration files"
echo "2. Configure Gemini API credentials"
echo "3. Start implementing the screens and features"