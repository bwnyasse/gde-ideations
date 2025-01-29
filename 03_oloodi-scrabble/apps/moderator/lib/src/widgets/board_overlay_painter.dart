import 'package:flutter/material.dart';

class BoardOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Calculate square size to maintain aspect ratio
    final squareSize = size.width < size.height ? size.width * 0.8 : size.height * 0.8;
    final left = (size.width - squareSize) / 2;
    final top = (size.height - squareSize) / 2;
    final rect = Rect.fromLTWH(left, top, squareSize, squareSize);

    // Draw the main square frame
    canvas.drawRect(rect, paint);

    // Draw corner markers for better alignment
    final cornerLength = squareSize * 0.1;
    final corners = [
      [rect.topLeft, Offset(rect.left + cornerLength, rect.top),
          Offset(rect.left, rect.top + cornerLength)],
      [rect.topRight, Offset(rect.right - cornerLength, rect.top),
          Offset(rect.right, rect.top + cornerLength)],
      [rect.bottomLeft, Offset(rect.left + cornerLength, rect.bottom),
          Offset(rect.left, rect.bottom - cornerLength)],
      [rect.bottomRight, Offset(rect.right - cornerLength, rect.bottom),
          Offset(rect.right, rect.bottom - cornerLength)],
    ];

    // Draw corner markers
    for (final corner in corners) {
      canvas.drawLine(corner[0] as Offset, corner[1] as Offset, paint);
      canvas.drawLine(corner[0] as Offset, corner[2] as Offset, paint);
    }

    // Draw grid lines with lower opacity
    paint
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0;

    // Draw 15x15 grid
    for (int i = 1; i < 15; i++) {
      // Vertical lines
      final x = left + (squareSize / 15) * i;
      canvas.drawLine(
        Offset(x, top),
        Offset(x, top + squareSize),
        paint,
      );

      // Horizontal lines
      final y = top + (squareSize / 15) * i;
      canvas.drawLine(
        Offset(left, y),
        Offset(left + squareSize, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}