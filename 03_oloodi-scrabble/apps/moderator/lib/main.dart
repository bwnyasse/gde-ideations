import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_moderator_app/src/screens/game_sessions_list_screen.dart';
import 'package:provider/provider.dart';
import 'src/providers/game_session_provider.dart';
import 'src/themes/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Storage
  FirebaseStorage.instance.setMaxUploadRetryTime(const Duration(seconds: 3));

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
        home: const GameSessionsListScreen(),
      ),
    );
  }
}
