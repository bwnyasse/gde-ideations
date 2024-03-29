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
    sb.writeln('${_getIndentation(depth)}${folder.name}');

    for (final subFolder in folder.subFolders) {
      _appendFolderStructure(sb, subFolder, depth + 1);
    }

    for (final file in folder.files) {
      sb.writeln('${_getIndentation(depth + 1)}${file.name}');
    }
  }

  String _getIndentation(int depth) {
    return '  ' * depth;
  }
}

class FileModel {
  final String name;
  final int size;

  FileModel({
    required this.name,
    required this.size,
  });
}