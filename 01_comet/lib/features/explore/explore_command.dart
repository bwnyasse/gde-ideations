import 'package:args/command_runner.dart';
import 'package:comet/features/explore/explore_service.dart';

class ExploreCommand extends Command<void> {
  @override
  final name = 'explore';
  @override
  final description = 'Explore the file system.';

  ExploreCommand() {
    argParser
      ..addOption(
        'level',
        abbr: 'L',
        defaultsTo: '0',
        help: 'Descend only level directories deep.',
      )
      ..addOption(
        'pattern',
        abbr: 'P',
        help:
            'List only those files that match the pattern given.',
      )
      ..addFlag(
        'directories',
        negatable: false,
        abbr: 'd',
        help: 'List directories only.',
      )
      ..addFlag(
        'size',
        negatable: false,
        abbr: 's',
        help: 'Print the size in bytes of each file.',
      )
      ..addFlag(
        'date',
        negatable: false,
        abbr: 'D',
        help: 'Print the date of last modification.',
      );
  }

  @override
  void run() async {
    final level = int.parse(argResults?['level']);
    final pattern = argResults?['pattern'];
    final dirOnly = argResults?['directories'];
    final showSize = argResults?['size'];
    final showDate = argResults?['date'];

    final folderService = ExploreService();
    final folderTree = await folderService.exploreFileSystem(
      level: level,
      pattern: pattern,
      dirOnly: dirOnly,
      showSize: showSize,
      showDate: showDate,
    );

    print(folderTree);
  }
}