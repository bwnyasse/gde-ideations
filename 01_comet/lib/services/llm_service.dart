import 'package:comet/models/insight_model.dart';

abstract class LLMService {
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
