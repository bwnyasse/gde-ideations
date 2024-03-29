import 'package:ansicolor/ansicolor.dart';

import 'file_model.dart';

class FolderModel {
  final String name;
  final List<FolderModel> subFolders;
  final List<FileModel> files;

  FolderModel({
    required this.name,
    required this.subFolders,
    required this.files,
  });

  @override
  String toString() {
    final sb = StringBuffer();
    _appendFolderStructure(sb, this, 0);
    return sb.toString();
  }

  void _appendFolderStructure(StringBuffer sb, FolderModel folder, int depth) {
    sb.writeln(
        '${_getIndentation(depth)}├── ${_getAnsiColorText(folder.name)}');

    for (final subFolder in folder.subFolders) {
      _appendFolderStructure(sb, subFolder, depth + 1);
    }

    for (final file in folder.files) {
      sb.writeln('${_getIndentation(depth + 1)}└── ${file.toString()}');
    }
  }

  String _getIndentation(int depth) {
    return '│   ' * depth;
  }

  String _getAnsiColorText(String text) {
    final pen = AnsiPen()..green(bold: true);
    return pen('\x1B[1m$text\x1B[0m');
  }
}
