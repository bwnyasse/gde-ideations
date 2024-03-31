import 'package:args/command_runner.dart';
import 'package:comet/features/insights/agents/gemini_agent.dart';
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
  static String dependencies =
      'Analyze project dependencies and provide insights.';
  static String projectStructure =
      'Analyze the project structure and provide recommendations.';
  static String performance =
      'Identify performance bottlenecks and provide optimization suggestions.';
  static String testability =
      "Assess the project's testability and provide coverage insights.";

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
        'dependencies',
        negatable: false,
        abbr: 'd',
        help: dependencies,
      )
      ..addFlag(
        'project-structure',
        negatable: false,
        abbr: 'p',
        help: projectStructure,
      )
      ..addFlag(
        'performance',
        negatable: false,
        abbr: 'r',
        help: performance,
      )
      ..addFlag(
        'testability',
        negatable: false,
        abbr: 't',
        help: testability,
      );
  }
  @override
  void run() async {
    final aiModel = argResults?['model'] as String? ?? 'gemini';
    final shouldProvideCodeOrganizationInsights =
        argResults?['code-organization'] as bool? ?? false;
    final shouldProvideCodeQualityInsights =
        argResults?['code-quality'] as bool? ?? false;
    final shouldProvideDependencyInsights =
        argResults?['dependencies'] as bool? ?? false;
    final shouldProvideProjectStructureInsights =
        argResults?['project-structure'] as bool? ?? false;
    final shouldProvidePerformanceInsights =
        argResults?['performance'] as bool? ?? false;
    final shouldProvideTestabilityInsights =
        argResults?['testability'] as bool? ?? false;

    final insights = <Insights>[];
    final InsightsService agent;
    switch (aiModel) {
      case 'gemini':
        agent = GeminiAgent();
        break;
      default:
        throw ArgumentError('Invalid AI model: $aiModel');
    }

    if (shouldProvideCodeOrganizationInsights) {
      insights.addAll(await agent.getCodeOrganizationInsights());
    }

    if (shouldProvideCodeQualityInsights) {
      insights.addAll(await agent.getCodeQualityInsights(''));
    }

    if (shouldProvideDependencyInsights) {
      insights.addAll(await agent.getCodeQualityInsights(''));
    }

    if (shouldProvideProjectStructureInsights) {
      insights.addAll(await agent.getCodeQualityInsights(''));
    }

    if (shouldProvidePerformanceInsights) {
      insights.addAll(await agent.getCodeQualityInsights(''));
    }

    if (shouldProvideTestabilityInsights) {
      insights.addAll(await agent.getCodeQualityInsights(''));
    }

    final output = InsightsOutput.formatInsights(insights);
    print(output);
  }
}
