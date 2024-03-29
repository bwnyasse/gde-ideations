import 'package:args/command_runner.dart';
import 'package:comet/services/folder_service.dart';

class ExploreCommand extends Command<void> {
  @override
  final name = 'explore';
  @override
  final description = 'Explore the file system';


  ExploreCommand() {
    argParser
      ..addOption(
        'depth',
        abbr: 'd',
        defaultsTo: '5',
        help: 'Depth limit for folder exploration',
      )
      ..addOption(
        'filter',
        abbr: 'f',
        help: 'Filter files and folders by name',
      );
  }

  @override
  void run() async {
    final depthLimit = int.parse(argResults?['depth']);
    final filter = argResults?['filter'];

    final folderService = FolderService();
    final folderTree = folderService.exploreFileSystem(
      depthLimit: depthLimit,
      filter: filter,
    );

    print(folderTree);
  }
}
