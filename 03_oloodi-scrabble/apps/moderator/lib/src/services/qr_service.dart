// lib/src/services/qr_service.dart
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

class QRService {
  // Generate QR code data
  String generateQRCodeData(String sessionId) {
    final data = {
      'sessionId': sessionId,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'scrabble_game',
    };
    
    return jsonEncode(data);
  }

  // Generate QR code widget
  Widget generateQRCode(String sessionId, {double size = 200}) {
    final data = generateQRCodeData(sessionId);
    
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
    );
  }
}

// lib/src/screens/qr_display_screen.dart
class QRDisplayScreen extends StatelessWidget {
  final String sessionId;
  final QRService _qrService = QRService();

  QRDisplayScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _qrService.generateQRCode(sessionId, size: 250),
                    const SizedBox(height: 16),
                    const Text(
                      'Scan this code with the Companion App',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Session ID: $sessionId',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}