import 'package:comet/features/explore/explore_service.dart';
import 'package:comet/features/insights/insights_command.dart';
import 'package:comet/features/insights/insights_model.dart';

abstract class InsightsService {
  final folderService = ExploreService();

  Future<List<Insights>> getCodeOrganizationInsights() async {
    final prompt = await getCodeOrganizationInsightsPrompt();
    final response = await generateInsight(prompt);
    return [
      Insights(
        title: InsightsCommand.codeOrganization,
        description: response,
      ),
    ];
  }

  Future<List<Insights>> getCodeQualityInsights() async {
    final prompt = await getCodeQualityInsightsPrompt();
    final response = await generateInsight(prompt);
    return [
      Insights(
        title: InsightsCommand.codeQuality,
        description: response,
      ),
    ];
  }

  Future<String> getCodeOrganizationInsightsPrompt();
  Future<String> getCodeQualityInsightsPrompt();
  Future<String> generateInsight(String prompt);
}
