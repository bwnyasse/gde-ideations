class MoveExplanation {
  final String text;
  final List<int>? audioData;
  final DateTime timestamp;

  MoveExplanation({
    required this.text,
    this.audioData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}