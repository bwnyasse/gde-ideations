import 'package:comet/features/insights/insights_service.dart';

class GPTAgent extends InsightsService {
  @override
  Future<String> generateInsight(String prompt) {
    throw UnimplementedError("Not implemented yet");
  }

  @override
  Future<String> getCodeOrganizationInsightsPrompt() {
    throw UnimplementedError("Not implemented yet");
  }

  @override
  Future<String> getCodeQualityInsightsPrompt() {
    throw UnimplementedError("Not implemented yet");
  }

  @override
  Future<String> getProjectOverviewInsightsPrompt() {
    throw UnimplementedError("Not implemented yet");
  }
}
