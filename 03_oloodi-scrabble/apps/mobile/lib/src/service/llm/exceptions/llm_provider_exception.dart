class LLMProviderException implements Exception {
  final String message;
  
  LLMProviderException(this.message);
  
  @override
  String toString() => 'LLMProviderException: $message';
}