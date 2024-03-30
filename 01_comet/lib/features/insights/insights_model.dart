class Insights {
  final String title;
  final String description;

  Insights({
    required this.title,
    required this.description,
  });

  @override
  String toString() {
    return '''
$title
$description
''';
  }
}
