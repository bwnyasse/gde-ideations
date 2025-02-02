// lib/main.dart
import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/ai_service_provider.dart';
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

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(prefs),
        ),
        ChangeNotifierProxyProvider<SettingsProvider, AIServiceProvider>(
          create: (context) => AIServiceProvider(
            context.read<SettingsProvider>(),
          ),
          update: (context, settings, previous) =>
              previous ?? AIServiceProvider(settings),
        ),
        ChangeNotifierProxyProvider2<SettingsProvider, AIServiceProvider,
            GameStateProvider>(
          create: (context) => GameStateProvider(
            context.read<AIServiceProvider>().service,
            context.read<SettingsProvider>(),
          ),
          update: (context, settings, aiServiceProvider, previous) =>
              previous ??
              GameStateProvider(aiServiceProvider.service, settings),
        ),
      ],
      child: const ScrabbleAIApp(),
    ),
  );
}

class ScrabbleAIApp extends StatelessWidget {
  const ScrabbleAIApp({super.key});

  @override
  Widget build(BuildContext context) {
// Access settings
    final settings = context.watch<SettingsProvider>();

// Access AI service
    final aiService = context.read<AIServiceProvider>().service;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => GameStateProvider(aiService, settings)),
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
