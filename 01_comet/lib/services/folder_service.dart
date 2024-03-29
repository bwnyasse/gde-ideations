import 'dart:io';
import 'package:path/path.dart' as path;

class FolderService {
  String exploreFileSystem({
    int depthLimit = 5,
    String? filter,
  }) {
    final rootDir = Directory.current;
    return _exploreDirectory(rootDir, 0, depthLimit, filter);
  }

  String _exploreDirectory(
    Directory directory,
    int currentDepth,
    int depthLimit,
    String? filter,
  ) {
    final sb = StringBuffer();

    if (currentDepth < depthLimit) {
      for (final entity in directory.listSync()) {
        if (entity is Directory) {
          if (_shouldIncludeEntity(entity.path, filter)) {
            sb.writeln('${_getIndentation(currentDepth)}${path.basename(entity.path)}');
            sb.write(_exploreDirectory(entity, currentDepth + 1, depthLimit, filter));
          }
        } else if (entity is File) {
          if (_shouldIncludeEntity(entity.path, filter)) {
            sb.writeln('${_getIndentation(currentDepth)}${path.basename(entity.path)}');
          }
        }
      }
    }

    return sb.toString();
  }

  bool _shouldIncludeEntity(String entityPath, String? filter) {
    return filter == null || path.basename(entityPath).contains(filter);
  }

  String _getIndentation(int depth) {
    return '  ' * depth;
  }
}