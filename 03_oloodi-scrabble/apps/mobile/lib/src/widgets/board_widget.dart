// lib/widgets/board_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state_provider.dart';
import '../models/board_square.dart';
import '../models/tile.dart';

// lib/widgets/board_widget.dart
class BoardWidget extends StatefulWidget {
  const BoardWidget({super.key});

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _scale = _transformationController.value.getMaxScaleOnAxis();
        _offset = details.focalPoint;
      },
      onScaleUpdate: (details) {
        final newScale = (_scale * details.scale).clamp(0.8, 2.0);
        final focalPoint = details.focalPoint;
        _transformationController.value = Matrix4.identity()
          ..translate(focalPoint.dx - _offset.dx, focalPoint.dy - _offset.dy)
          ..scale(newScale);
      },
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.8,
        maxScale: 2.0,
        child: Consumer<GameStateProvider>(
          builder: (context, gameState, child) {
            return AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 15,
                  childAspectRatio: 1,
                ),
                itemCount: 225,
                itemBuilder: (context, index) {
                  final row = index ~/ 15;
                  final col = index % 15;
                  final square = gameState.board[row][col];

                  return _buildSquare(square, gameState);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSquare(BoardSquare square, GameStateProvider gameState) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        color: _getSquareColor(square.type),
      ),
      child: square.tile != null
          ? _buildTile(square.tile!, gameState)
          : _buildSquareContent(square.type),
    );
  }

  Widget _buildTile(Tile tile, GameStateProvider gameState) {
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
            border: Border.all(
              color: player.color,
              width: 2,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Letter - left aligned
              Positioned(
                left: 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    tile.letter,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              // Points - right aligned
              Positioned(
                right: 2,
                bottom: 1,
                child: Text(
                  '${tile.points}',
                  style: const TextStyle(
                    fontSize: 7,
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
          fontSize: 10,
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
      case SquareType.normal:
        return Colors.white;

      case SquareType.doubleLetter:
        return Colors.lightBlue[50]!; // Light blue

      case SquareType.tripleLetter:
        return const Color.fromARGB(255, 131, 192, 242); // Dark blue

      case SquareType.doubleWord:
        return Colors.pink[50]!; // Pink

      case SquareType.tripleWord:
        return const Color.fromARGB(255, 240, 113, 125); // Red

      case SquareType.center:
        return Colors.pink[50]!; // Same as DW
    }
  }
}
