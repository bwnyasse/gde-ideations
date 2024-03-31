class InsightsException implements Exception {
  final dynamic origin ;
  final String message;
  final StackTrace stackTrace;

  InsightsException(this.message, this.origin, this.stackTrace);

  @override
  String toString() {
    return 'InsightsException: $message';
  }
}