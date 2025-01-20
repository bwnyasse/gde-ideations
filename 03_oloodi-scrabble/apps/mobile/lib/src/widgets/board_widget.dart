import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/models/board.dart';
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
              crossAxisCount: Board.boardSize,
            ),
            itemCount: Board.boardSize * Board.boardSize,
            itemBuilder: (context, index) {
              final row = index ~/ Board.boardSize;
              final col = index % Board.boardSize;
              final tile = gameState.board.tiles[row][col];

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                ),
                child: tile != null ? Center(child: Text(tile.letter)) : null,
              );
            },
          ),
        );
      },
    );
  }
}
