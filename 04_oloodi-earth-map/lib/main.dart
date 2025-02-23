import 'package:flutter/material.dart';

void main() {
  runApp(const OloodiWorldApp());
}

class OloodiWorldApp extends StatelessWidget {
  const OloodiWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oloodi World',
      home: const OloodiWorldHomePage(),
    );
  }
}

class OloodiWorldHomePage extends StatelessWidget {
  const OloodiWorldHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World'), // Title Bar
      ),
      body: Row( // Main Area (Row for 1/3 and 2/3 split)
        children: [
          Expanded( // Info Area (1/3)
            flex: 1, // 1/3
            child: Column(
              children: [
                const Text('Welcome to Oloodi World!'), // Welcome Message
                const Text('What do you want to see?'), // Prompt
                // Explore Prompts (Placeholders for now)
                Expanded(
                  child: ListView(
                    children: const [
                      ListTile(title: Text("Where is Paris?")),
                      ListTile(title: Text("Tell me about lions")),
                      // ... more prompts
                    ],
                  ),
                ),
                const Text('Did You Know? (Rotating Facts)'), // Facts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Icon(Icons.mic), // Microphone
                    Icon(Icons.settings), // Settings
                  ],
                ),
              ],
            ),
          ),
          Expanded( // Globe Area (2/3)
            flex: 2, // 2/3
            child: Container(
              color: Colors.blue, // Placeholder for the globe
              child: const Center(child: Text("3D Globe Here")), // Globe
            ),
          ),
        ],
      ),
    );
  }
}