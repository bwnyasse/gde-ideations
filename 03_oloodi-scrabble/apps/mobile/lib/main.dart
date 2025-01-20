import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/game_state_provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/screens/home_screen.dart';

void main() {
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
        title: 'Scrabble AI',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}