import 'package:comet/features/insights/insights_command.dart';
import 'package:comet/features/insights/insights_model.dart';

abstract class InsightsService {
  Future<List<Insights>> getCodeOrganizationInsights(final prompt) async {
    final response = await generateInsight(prompt);
    return [
      Insights(
        title: InsightsCommand.codeOrganization,
        description: response,
      ),
    ];
  }

  Future<List<Insights>> getCodeQualityInsights(final prompt) async {
    final response = await generateInsight(prompt);
    return [
      Insights(
        title: InsightsCommand.codeQuality,
        description: response,
      ),
    ];
  }

  Future<String> generateInsight(String prompt);
}
