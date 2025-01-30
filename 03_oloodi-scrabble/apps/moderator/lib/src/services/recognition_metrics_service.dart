// lib/src/services/recognition_metrics_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RecognitionMetrics {
  final String sessionId;
  final String moveId;
  final int totalTiles;
  final int correctedTiles;
  final Map<String, dynamic> originalValues;
  final Map<String, dynamic> correctedValues;
  final DateTime timestamp;

  RecognitionMetrics({
    required this.sessionId,
    required this.moveId,
    required this.totalTiles,
    required this.correctedTiles,
    required this.originalValues,
    required this.correctedValues,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'moveId': moveId,
    'totalTiles': totalTiles,
    'correctedTiles': correctedTiles,
    'accuracyRate': (totalTiles - correctedTiles) / totalTiles,
    'originalValues': originalValues,
    'correctedValues': correctedValues,
    'timestamp': Timestamp.fromDate(timestamp),
  };
}

class RecognitionMetricsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveMetrics(RecognitionMetrics metrics) async {
    try {
      // Store in a subcollection under the game session
      await _firestore
          .collection('game_sessions')
          .doc(metrics.sessionId)
          .collection('recognition_metrics')
          .add(metrics.toJson());
      
      // Also store in a global metrics collection for easier analysis
      await _firestore
          .collection('recognition_metrics')
          .add(metrics.toJson());
    } catch (e) {
      print('Error saving recognition metrics: $e');
      rethrow;
    }
  }

  // Get metrics for a specific session
  Future<List<RecognitionMetrics>> getSessionMetrics(String sessionId) async {
    try {
      final snapshot = await _firestore
          .collection('game_sessions')
          .doc(sessionId)
          .collection('recognition_metrics')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return RecognitionMetrics(
          sessionId: data['sessionId'],
          moveId: data['moveId'],
          totalTiles: data['totalTiles'],
          correctedTiles: data['correctedTiles'],
          originalValues: data['originalValues'],
          correctedValues: data['correctedValues'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      print('Error getting session metrics: $e');
      rethrow;
    }
  }

  // Get overall accuracy statistics
  Future<Map<String, dynamic>> getOverallStats() async {
    try {
      final snapshot = await _firestore
          .collection('recognition_metrics')
          .get();

      final metrics = snapshot.docs.map((doc) => doc.data()).toList();
      
      final totalMoves = metrics.length;
      final totalAccuracy = metrics.fold<double>(
        0,
        (sum, metric) => sum + metric['accuracyRate'],
      );

      return {
        'totalMoves': totalMoves,
        'averageAccuracy': totalMoves > 0 ? totalAccuracy / totalMoves : 0,
        'lastUpdated': DateTime.now(),
      };
    } catch (e) {
      print('Error getting overall stats: $e');
      rethrow;
    }
  }
}