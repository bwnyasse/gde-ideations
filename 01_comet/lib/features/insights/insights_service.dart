import 'package:comet/features/insights/agents/gemini_agent.dart';
import 'package:comet/models/insight_model.dart';

class AIService {
  final String _aiModel;

  AIService(this._aiModel);

  Future<List<Insight>> generateInsights({
    bool shouldProvideCodeOrganizationInsights = false,
    bool shouldProvideCodeQualityInsights = false,
    bool shouldProvideDependencyInsights = false,
    bool shouldProvideProjectStructureInsights = false,
    bool shouldProvidePerformanceInsights = false,
    bool shouldProvideTestabilityInsights = false,
  }) async {
    final insights = <Insight>[];
    LLMAgent agent;
    switch (_aiModel) {
      case 'gemini':
        agent = GeminiAgent();
        break;
      default:
        throw ArgumentError('Invalid AI model: $_aiModel');
    }

    return insights;
  }
}


abstract class LLMAgent {
  Future<List<Insight>> getCodeOrganizationInsights(final prompt) async {
    final response = await generateInsight(prompt);
    return [
      Insight(
        title: 'Improve Folder Organization',
        description: response,
      ),
    ];
  }

  Future<List<Insight>> getCodeQualityInsights(final prompt) async {
    final response = await generateInsight(prompt);
    return [
      Insight(
        title: 'Improve Code Quality',
        description: response,
      ),
    ];
  }

  Future<String> generateInsight(String prompt);
}
