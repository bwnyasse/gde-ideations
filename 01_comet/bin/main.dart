import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:comet/features/explore/explore_command.dart';
import 'package:comet/features/form/form_command.dart';
import 'package:comet/features/insights/insights_command.dart';

Future<void> main(List<String> arguments) async {
  final runner = CometCommand(
    'comet',
    'The Comet : an AI-Powered Folder Explorer',
  )
    ..addCommand(ExploreCommand())
    ..addCommand(InsightsCommand())
    ..addCommand(FormCommand());

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
    final pen = AnsiPen()..red(bold: true);
    print("${pen('Error while running Comet:')}\n");
    print('$error');
    print("\n${pen('Overview:')}\n");
    runner.printUsage();
  }
}

class CometCommand extends CompletionCommandRunner<void> {
  CometCommand(super.executableName, super.description);
  @override
  bool get enableAutoInstall => true;
}
