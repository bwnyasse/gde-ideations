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
}