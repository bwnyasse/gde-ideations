import 'package:comet/features/insights/insights_service.dart';
import 'package:dotenv/dotenv.dart';

class ClaudeAgent extends InsightsService {
  @override
  String getApiKey(DotEnv env) => '';

  @override
  Future<String> generateInsight(String apiKey, String prompt) async {
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

  @override
  Future<String> getUpdateReadmeInsightsPrompt() {
    throw UnimplementedError("Not implemented yet");
  }
}
