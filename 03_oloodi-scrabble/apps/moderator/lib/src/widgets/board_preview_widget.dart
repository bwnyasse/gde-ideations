// lib/src/widgets/board_preview_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/board_config.dart';
import '../models/board_square.dart';
import '../providers/game_session_provider.dart';
import '../services/firebase_service.dart';

class BoardPreviewWidget extends StatelessWidget {
  const BoardPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Consumer<GameSessionProvider>(
        builder: (context, provider, child) {
          return StreamBuilder<Map<String, dynamic>>(
            stream: FirebaseService().getBoardState(provider.currentSession!.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final boardState = snapshot.data!;
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 15,
                  childAspectRatio: 1,
                ),
                itemCount: 225, // 15x15 grid
                itemBuilder: (context, index) {
                  final row = index ~/ 15;
                  final col = index % 15;
                  return _buildSquare(context, boardState, row, col);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSquare(BuildContext context, Map<String, dynamic> boardState, int row, int col) {
    final squareData = boardState['$row-$col'] as Map<String, dynamic>?;
    final squareType = BoardConfig.getSquareType(row, col);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        color: BoardConfig.getSquareColor(squareType),
      ),
      child: squareData?['letter'] != null
          ? _buildTile(context, squareData!)
          : _buildSquareLabel(squareType),
    );
  }

  Widget _buildTile(BuildContext context, Map<String, dynamic> tileData) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: const Color(0xFFF7D698),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              tileData['letter'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            right: 2,
            bottom: 1,
            child: Text(
              '${tileData['points']}',
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareLabel(SquareType type) {
    final label = BoardConfig.getSquareLabel(type);
    if (label.isEmpty) return const SizedBox();

    return Center(
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }
}