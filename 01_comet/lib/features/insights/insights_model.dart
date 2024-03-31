import 'package:ansicolor/ansicolor.dart';

class Insights {
  final String title;
  final String description;

  Insights({
    required this.title,
    required this.description,
  });

  @override
  String toString() {
    final pen = AnsiPen()..green(bold: true);
    return '''
${pen(title)}

$description
''';
  }
}

class InsightsOutput {
  static String formatInsights(List<Insights> insights) {
    if (insights.isEmpty) {
      return "Nothing to display";
    }

    final sb = StringBuffer();
    for (int i = 0; i < insights.length; i++) {
      final insight = insights[i];
      sb.writeln("== Request : ${insight.toString()}");
    }
    return sb.toString();
  }
}