// lib/widgets/board_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state_provider.dart';
import '../models/board_square.dart';
import '../models/tile.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

  // Classic Scrabble tile color
  static const Color scrabbleTileColor = Color(0xFFF7D698); // Light yellow/beige

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20.0),
          minScale: 0.5,
          maxScale: 2.5,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 15,
              childAspectRatio: 1,
            ),
            itemCount: 225,
            itemBuilder: (context, index) {
              final row = index ~/ 15;
              final col = index % 15;
              final square = gameState.board[row][col];
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  color: _getSquareColor(square.type),
                ),
                child: square.tile != null
                    ? _buildTile(square.tile!, gameState)
                    : _buildSquareContent(square.type),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTile(Tile tile, GameStateProvider gameState) {
    // Find the player who placed this tile
    final player = gameState.players.firstWhere(
      (p) => p.id == tile.playerId,
      orElse: () => gameState.players[0],
    );

    return AnimatedScale(
      scale: tile.isNew ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      child: AnimatedRotation(
        turns: tile.isNew ? -0.5 : 0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: scrabbleTileColor,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
            border: Border.all(
              color: player.color,
              width: 2.5,
            ),
          ),
          child: Stack(
            children: [
              // Letter
              Center(
                child: Text(
                  tile.letter,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Points
              Positioned(
                right: 2,
                bottom: 2,
                child: Text(
                  '${tile.points}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquareContent(SquareType type) {
    String label = '';
    switch (type) {
      case SquareType.tripleWord:
        label = 'TW';
        break;
      case SquareType.doubleWord:
        label = 'DW';
        break;
      case SquareType.tripleLetter:
        label = 'TL';
        break;
      case SquareType.doubleLetter:
        label = 'DL';
        break;
      case SquareType.center:
        label = '★';
        break;
      default:
        return const SizedBox();
    }

    return Center(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _getSquareColor(type).computeLuminance() > 0.5
              ? Colors.black54
              : Colors.white70,
        ),
      ),
    );
  }

  Color _getSquareColor(SquareType type) {
    switch (type) {
      case SquareType.tripleWord:
        return Colors.red[100]!;
      case SquareType.doubleWord:
        return Colors.pink[50]!;
      case SquareType.tripleLetter:
        return Colors.blue[100]!;
      case SquareType.doubleLetter:
        return Colors.lightBlue[50]!;
      case SquareType.center:
        return Colors.pink[50]!;
      default:
        return Colors.white;
    }
  }
}