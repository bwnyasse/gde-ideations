// lib/main.dart
import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/themes/app_themes.dart';
import 'package:provider/provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/game_state_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ScrabbleAIApp());
}

class ScrabbleAIApp extends StatelessWidget {
  const ScrabbleAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameStateProvider()),
      ],
      child: MaterialApp(
        title: 'Oloodi Scrabble Companion',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false, // Remove debug banner
        home: const HomeScreen(),
      ),
    );
  }
}
