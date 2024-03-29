import 'package:args/command_runner.dart';

class VersionCommand extends Command<void> {
  @override
  final name = 'version';
  @override
  final description = 'Show the Comet version';


  @override
  void run() => print('version 0.0.1');
}
