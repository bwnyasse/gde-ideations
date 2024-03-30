class Insight {
  final String title;
  final String description;

  Insight({
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
