// lib/src/widgets/board_preview_widget.dart
import 'package:flutter/material.dart';
import '../models/board_square.dart';
import '../services/score_calculator.dart';

class BoardPreviewWidget extends StatelessWidget {
  final List<Map<String, dynamic>> newTiles;
  final List<List<BoardSquare>> currentBoard;
  final bool isFirstMove;

  const BoardPreviewWidget({
    super.key,
    required this.newTiles,
    required this.currentBoard,
    required this.isFirstMove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 15,
          childAspectRatio: 1,
        ),
        itemCount: 225,
        itemBuilder: (context, index) {
          final row = index ~/ 15;
          final col = index % 15;
          
          // Find if there's a new tile at this position
          final newTile = newTiles.firstWhere(
            (tile) => tile['row'] == row && tile['col'] == col,
            orElse: () => {'letter': null},
          );

          // Get existing tile
          final existingTile = currentBoard[row][col].tile;
          
          // Get square type
          final squareType = ScoreCalculator.getSquareType(row, col);
          
          return _buildSquare(
            context,
            row: row,
            col: col,
            squareType: squareType,
            newTile: newTile['letter'] != null ? newTile : null,
            existingTile: existingTile,
          );
        },
      ),
    );
  }

  Widget _buildSquare(
    BuildContext context, {
    required int row,
    required int col,
    required SquareType squareType,
    Map<String, dynamic>? newTile,
    dynamic existingTile,
  }) {
    final isNewTilePlacement = newTile != null;
    final hasExistingTile = existingTile != null;
    
    Color getBackgroundColor() {
      if (isNewTilePlacement) return Colors.yellow[100]!;
      if (hasExistingTile) return Colors.brown[100]!;
      
      switch (squareType) {
        case SquareType.tripleWord:
          return Colors.red[100]!;
        case SquareType.doubleWord:
          return Colors.pink[50]!;
        case SquareType.tripleLetter:
          return Colors.blue[100]!;
        case SquareType.doubleLetter:
          return Colors.lightBlue[50]!;
        default:
          return Colors.white;
      }
    }

    String getMultiplierLabel() {
      switch (squareType) {
        case SquareType.tripleWord:
          return 'TW';
        case SquareType.doubleWord:
          return 'DW';
        case SquareType.tripleLetter:
          return 'TL';
        case SquareType.doubleLetter:
          return 'DL';
        default:
          return '';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: getBackgroundColor(),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          if (!isNewTilePlacement && !hasExistingTile && getMultiplierLabel().isNotEmpty)
            Center(
              child: Text(
                getMultiplierLabel(),
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey[600],
                ),
              ),
            ),
          if (isNewTilePlacement || hasExistingTile)
            Center(
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isNewTilePlacement ? Colors.yellow : Colors.brown[200],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  isNewTilePlacement ? newTile!['letter'] : existingTile.letter,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isNewTilePlacement ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          if (row == 7 && col == 7 && !hasExistingTile && !isNewTilePlacement)
            const Center(
              child: Text(
                '★',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.pink,
                ),
              ),
            ),
        ],
      ),
    );
  }
}