import 'package:comet/models/insight_model.dart';
import 'package:comet/services/folder_service.dart';

abstract class LLMService {
  Future<List<Insight>> getCodeOrganizationInsights(FolderService folderService);
  Future<List<Insight>> getCodeQualityInsights(FolderService folderService);
  Future<List<Insight>> getDependencyInsights(FolderService folderService);
  Future<List<Insight>> getProjectStructureInsights(FolderService folderService);
  Future<List<Insight>> getPerformanceInsights(FolderService folderService);
  Future<List<Insight>> getTestabilityInsights(FolderService folderService);
}