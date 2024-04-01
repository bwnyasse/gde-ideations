import 'package:ansicolor/ansicolor.dart';

enum InsightType {
  projectOverview,
  codeOrganization,
  codeQuality,
  updateReadme,
}

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

extension InsightsExtension on List<Insights> {
  String format() {
    if (isEmpty) {
      return "Nothing to display";
    }

    final sb = StringBuffer();
    for (final insight in this) {
      sb.writeln("## Request : ${insight.toString()}");
    }
    return sb.toString();
  }
}
