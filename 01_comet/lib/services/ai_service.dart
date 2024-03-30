import 'package:comet/models/insight_model.dart';
import 'package:comet/services/folder_service.dart';
import 'package:comet/services/gemini_service.dart';
import 'package:comet/services/llm_service.dart';

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
    final folderService = FolderService();
    final insights = <Insight>[];
    LLMService llmService;
    switch (_aiModel) {
      case 'gemini':
        llmService = GeminiService();
        break;
      default:
        throw ArgumentError('Invalid AI model: $_aiModel');
    }

    // Generate other insights
    // ...

    return insights;
  }
}
