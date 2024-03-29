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
        defaultsTo: '0',
        help: 'Depth limit for folder exploration',
      )
      ..addOption(
        'filter',
        abbr: 'f',
        help: 'Filter files and folders by name',
      )
      ..addFlag(
        'directories',
        abbr: 'D',
        help: 'List directories only',
      )
      ..addFlag(
        'size',
        abbr: 's',
        help: 'Print the size in bytes of each file',
      )
      ..addFlag(
        'sort-by-time',
        abbr: 't',
        help: 'Sort files by last modification time',
      );
  }

  @override
  void run() async {
    final depthLimit = int.parse(argResults?['depth']);
    final filter = argResults?['filter'];
    final directories = argResults?['directories'];
    final size = argResults?['size'];
    final sort_by_time = argResults?['sort-by-time'];

    final folderService = FolderService();
    final folderTree = await folderService.exploreFileSystem(
      depthLimit: depthLimit,
      filter: filter,
    );

    print(folderTree);
  }
}
