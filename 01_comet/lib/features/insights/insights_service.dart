import 'package:comet/features/explore/explore_service.dart';
import 'package:comet/features/insights/insights_command.dart';
import 'package:comet/features/insights/insights_exception.dart';
import 'package:comet/features/insights/insights_model.dart';
import 'package:dotenv/dotenv.dart';

abstract class InsightsService {
  final folderService = ExploreService();

  Future<List<Insights>> getInsights(InsightType insightType) async {
    try {
      var env = DotEnv(includePlatformEnvironment: true)..load();

      final apiKey = getApiKey(env);
      final prompt = await getInsightsPrompt(insightType);
      final response = await generateInsight(apiKey, prompt);
      return [
        Insights(
          title: _getInsightTitle(insightType),
          description: response,
        ),
      ];
    } catch (e, stackTrace) {
      final errorMessage = 'Error generating insight for $insightType';
      throw InsightsException(errorMessage, e, stackTrace);
    }
  }

  Future<String> getInsightsPrompt(InsightType insightType) async {
    switch (insightType) {
      case InsightType.projectOverview:
        return await getProjectOverviewInsightsPrompt();
      case InsightType.codeOrganization:
        return await getCodeOrganizationInsightsPrompt();
      case InsightType.codeQuality:
        return await getCodeQualityInsightsPrompt();
      case InsightType.updateReadme:
        return await getUpdateReadmeInsightsPrompt();
      case InsightType.fileManagement:
        return await getFileManagementInsightsPrompt();
    }
  }

  String _getInsightTitle(InsightType insightType) {
    switch (insightType) {
      case InsightType.projectOverview:
        return InsightsCommand.projectOverview;
      case InsightType.codeOrganization:
        return InsightsCommand.codeOrganization;
      case InsightType.codeQuality:
        return InsightsCommand.codeQuality;
      case InsightType.updateReadme:
        return InsightsCommand.updateReadme;
      case InsightType.fileManagement:
        return InsightsCommand.fileManagement;
    }
  }

  String getApiKey(DotEnv env);
  Future<String> getUpdateReadmeInsightsPrompt();
  Future<String> getProjectOverviewInsightsPrompt();
  Future<String> getCodeOrganizationInsightsPrompt();
  Future<String> getCodeQualityInsightsPrompt();
  Future<String> getFileManagementInsightsPrompt();
  Future<String> generateInsight(String apiKey, String prompt);
}
