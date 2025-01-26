import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/board_square.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/tile.dart';
import 'package:provider/provider.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/game_state_provider.dart';
class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

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
            itemCount: 225, // 15x15
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
                    ? _buildTile(square.tile!)
                    : _buildSquareContent(square.type),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTile(Tile tile) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.orange[100],
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
              tile.letter,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            right: 2,
            bottom: 2,
            child: Text(
              '${tile.points}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
        return Colors.red[200]!;
      case SquareType.doubleWord:
        return Colors.pink[100]!;
      case SquareType.tripleLetter:
        return Colors.blue[200]!;
      case SquareType.doubleLetter:
        return Colors.lightBlue[100]!;
      case SquareType.center:
        return Colors.pink[100]!;
      default:
        return Colors.white;
    }
  }
}
