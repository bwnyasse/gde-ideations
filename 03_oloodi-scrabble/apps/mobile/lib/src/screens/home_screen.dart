import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/widgets/board_widget.dart';
import 'package:oloodi_scrabble_end_user_app/src/widgets/camera_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scrabble AI')),
      body: Column(
        children: [
          const Expanded(child: BoardWidget()),
          const CameraWidget(),
          // Additional widgets will be added here
        ],
      ),
    );
  }
}