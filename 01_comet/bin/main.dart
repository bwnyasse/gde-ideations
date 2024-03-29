import 'package:args/command_runner.dart';
import 'package:comet/commands/explore_command.dart';
import 'package:comet/commands/version_command.dart';

Future<void> main(List<String> arguments) async {
  final runner =
      CommandRunner<void>('comet', 'The Comet : an AI-Powered Folder Explorer')
        ..addCommand(ExploreCommand())
        ..addCommand(VersionCommand());

  try {
    await runner.run(arguments);
  } catch (error) {
    print('Error: $error');
    runner.printUsage();
  }
}
