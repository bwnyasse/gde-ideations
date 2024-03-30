import 'package:args/command_runner.dart';
import 'package:comet/features/insights/insights_service.dart';
import 'package:comet/features/explore/explore_service.dart';

class InsightsCommand extends Command<void> {
  @override
  final name = 'insights';
  @override
  final description = 'Provide AI-powered insights.';

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
        help:
            'Provide recommendations for better code organization and structure.',
      )
      ..addFlag(
        'code-quality',
        negatable: false,
        abbr: 'q',
        help: 'Identify potential code quality issues and provide suggestions.',
      )
      ..addFlag(
        'dependencies',
        negatable: false,
        abbr: 'd',
        help: 'Analyze project dependencies and provide insights.',
      )
      ..addFlag(
        'project-structure',
        negatable: false,
        abbr: 'p',
        help: 'Analyze the project structure and provide recommendations.',
      )
      ..addFlag(
        'performance',
        negatable: false,
        abbr: 'r',
        help:
            'Identify performance bottlenecks and provide optimization suggestions.',
      )
      ..addFlag(
        'testability',
        negatable: false,
        abbr: 't',
        help: "Assess the project's testability and provide coverage insights.",
      );
  }

  @override
  void run() async {
    final aiModel = argResults?['model'] as String? ?? 'gemini';
    final shouldProvideCodeOrganizationInsights =
        argResults?['code-organization'];
    final shouldProvideCodeQualityInsights = argResults?['code-quality'];
    final shouldProvideDependencyInsights = argResults?['dependencies'];
    final shouldProvideProjectStructureInsights =
        argResults?['project-structure'];
    final shouldProvidePerformanceInsights = argResults?['performance'];
    final shouldProvideTestabilityInsights = argResults?['testability'];


    final aiService = AIService(aiModel);
    final insights = await aiService.generateInsights(
      
      shouldProvideCodeOrganizationInsights:
          shouldProvideCodeOrganizationInsights,
      shouldProvideCodeQualityInsights: shouldProvideCodeQualityInsights,
      shouldProvideDependencyInsights: shouldProvideDependencyInsights,
      shouldProvideProjectStructureInsights:
          shouldProvideProjectStructureInsights,
      shouldProvidePerformanceInsights: shouldProvidePerformanceInsights,
      shouldProvideTestabilityInsights: shouldProvideTestabilityInsights,
    );

    print(insights);
  }
}
