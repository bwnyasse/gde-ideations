import 'package:ansicolor/ansicolor.dart';
import 'package:args/command_runner.dart';
import 'package:comet/features/insights/agents/gemini_agent.dart';
import 'package:comet/features/insights/insights_exception.dart';
import 'package:comet/features/insights/insights_model.dart';
import 'package:comet/features/insights/insights_service.dart';

class InsightsCommand extends Command<void> {
  @override
  final name = 'insights';
  @override
  final description = 'Provide AI-powered insights.';

  static String codeOrganization =
      'Provide recommendations for better code organization and structure.';
  static String codeQuality =
      'Identify potential code quality issues and provide suggestions.';
  static String projectOverview =
      'Analyze the project and provide an overview.';
  static String updateReadme =
      'Provide an update version of the project README.';

  InsightsCommand() {
    argParser
      ..addOption(
        'model',
        abbr: 'm',
        defaultsTo: 'gemini',
        help: 'AI model to use for insights (e.g., Gemini, OpenAI, Claude).',
      )
      ..addFlag(
        'code-organization',
        negatable: false,
        abbr: 'o',
        help: codeOrganization,
      )
      ..addFlag(
        'code-quality',
        negatable: false,
        abbr: 'q',
        help: codeQuality,
      )
      ..addFlag(
        'project-overview',
        negatable: false,
        abbr: 'p',
        help: projectOverview,
      )
      ..addFlag(
        'update-readme',
        negatable: false,
        abbr: 'r',
        help: updateReadme,
      );
  }

  @override
  void run() async {
    try {
      final aiModel = argResults?['model'] as String? ?? 'gemini';
      final selectedInsightTypes = <InsightType>[];
      if (argResults?['code-organization'] as bool? ?? false) {
        selectedInsightTypes.add(InsightType.codeOrganization);
      }
      if (argResults?['code-quality'] as bool? ?? false) {
        selectedInsightTypes.add(InsightType.codeQuality);
      }
      if (argResults?['project-overview'] as bool? ?? false) {
        selectedInsightTypes.add(InsightType.projectOverview);
      }
      if (argResults?['update-readme'] as bool? ?? false) {
        selectedInsightTypes.add(InsightType.projectOverview);
      }

      if (selectedInsightTypes.length != 1) {
        throw ArgumentError('Only one of the insights flags can be set.');
      }

      final insights = <Insights>[];
      final InsightsService agent;
      switch (aiModel) {
        case 'gemini':
          agent = GeminiAgent();
          break;
        default:
          throw ArgumentError('Invalid AI model: $aiModel');
      }

      for (final insightType in selectedInsightTypes) {
        insights.addAll(await agent.getInsights(insightType));
      }

      final output = insights.format();
      print(output);
    } catch (error, stackTrace) {
      if (error is InsightsException) {
        final pen = AnsiPen()..red(bold: true);
        print("${pen('Error while generating insights:')}\n");
        print(error.message);
        print("${pen('Stack Trace:')}\n$stackTrace");
        print(
            "${pen('Origin:')}\n${error.origin}:\n${error.origin.message}\n${error.stackTrace}");
      }
    }
  }
}
