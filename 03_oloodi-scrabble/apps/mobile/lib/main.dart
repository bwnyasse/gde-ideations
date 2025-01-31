// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/settings_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/screens/game_sessions_list_screen.dart';
import 'package:oloodi_scrabble_end_user_app/src/themes/app_themes.dart';
import 'package:provider/provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/game_state_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Make sure to add this line
  await dotenv.load(fileName: ".env");

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameStateProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
      ],
      child: const ScrabbleAIApp(),
    ),
  );
}

class ScrabbleAIApp extends StatelessWidget {
  const ScrabbleAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameStateProvider()),
      ],
      child: MaterialApp(
        title: 'Oloodi Scrabble Companion',
        theme: AppTheme.getThemeData(settings.themeMode), // Use 
        debugShowCheckedModeBanner: false,
        home: const GameSessionsListScreen(),
      ),
    );
  }

}
