import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oloodi_scrabble_moderator_app/src/services/recognition_metrics_service.dart';

class MetricsViewer extends StatelessWidget {
  final String sessionId;
  final RecognitionMetricsService _metricsService = RecognitionMetricsService();

  MetricsViewer({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecognitionMetrics>>(
      future: _metricsService.getSessionMetrics(sessionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final metrics = snapshot.data ?? [];
        if (metrics.isEmpty) {
          return const Center(child: Text('No recognition metrics available'));
        }

        final totalAccuracy = metrics.fold<double>(
          0,
          (sum, metric) =>
              sum +
              ((metric.totalTiles - metric.correctedTiles) / metric.totalTiles),
        );
        final averageAccuracy = totalAccuracy / metrics.length;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recognition Accuracy: ${(averageAccuracy * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text('Total Moves: ${metrics.length}'),
                Text(
                    'Total Corrections: ${metrics.fold<int>(0, (sum, m) => sum + m.correctedTiles)}'),
                const SizedBox(height: 16),
                const Text('Recent Corrections:'),
                Expanded(
                  child: ListView.builder(
                    itemCount: metrics.length,
                    itemBuilder: (context, index) {
                      final metric = metrics[index];
                      return ListTile(
                        title: Text('Move ${index + 1}'),
                        subtitle: Text(
                          'Accuracy: ${((metric.totalTiles - metric.correctedTiles) / metric.totalTiles * 100).toStringAsFixed(1)}% '
                          '(${metric.correctedTiles} corrections)',
                        ),
                        trailing: Text(
                          DateFormat.yMd().add_jm().format(metric.timestamp),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
