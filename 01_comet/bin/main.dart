import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:comet/features/explore/explore_command.dart';
import 'package:comet/features/insights/insights_command.dart';

Future<void> main(List<String> arguments) async {
  final runner =
      CommandRunner<void>('comet', 'The Comet : an AI-Powered Folder Explorer')
        ..addCommand(ExploreCommand())
        ..addCommand(InsightsCommand());

  // Add the version option to the command runner.
  runner.argParser.addFlag(
    'version',
    negatable: false,
    help: 'Print the Comet version.',
    callback: (version) {
      if (version) {
        print('Comet version: 0.0.1 (dev) on "macos_arm64"');
        exit(0);
      }
    },
  );

  try {
    await runner.run(arguments);
  } catch (error) {
    print('Error: $error');
    runner.printUsage();
  }
}
