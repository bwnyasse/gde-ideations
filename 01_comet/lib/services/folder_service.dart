import 'dart:io';
import 'package:comet/models/folder_model.dart';
import 'package:path/path.dart' as path;

class FolderService {
  Future<FolderModel> exploreFileSystem({
    int depthLimit = 5,
    String? filter,
  }) async {
    final rootDir = Directory.current;
    return _exploreDirectory(rootDir, 0, depthLimit, filter);
  }

  Future<int> _getFolderSize(Directory directory) async {
    int totalSize = 0;
    await for (final entity
        in directory.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }

  Future<FolderModel> _exploreDirectory(
    Directory directory,
    int currentDepth,
    int depthLimit,
    String? filter,
  ) async {
    final subFolders = <FolderModel>[];
    final files = <FileModel>[];

    for (final entity in directory.listSync()) {
      if (entity is Directory) {
        if (_shouldIncludeEntity(entity.path, filter)) {
          if (currentDepth < depthLimit) {
            subFolders.add(
              await _exploreDirectory(
                entity,
                currentDepth + 1,
                depthLimit,
                filter,
              ),
            );
          } else {
            final folderSize = await _getFolderSize(entity);
            subFolders.add(
              FolderModel(
                name: path.basename(entity.path),
                subFolders: [],
                files: [],
                size: folderSize,
              ),
            );
          }
        }
      } else if (entity is File) {
        if (_shouldIncludeEntity(entity.path, filter)) {
          final fileSize = await entity.length();
          files.add(FileModel(
            name: path.basename(entity.path),
            size: fileSize,
          ));
        }
      }
    }

    final folderSize = files.fold<int>(0, (sum, file) => sum + file.size) +
        subFolders.fold<int>(0, (sum, folder) => sum + folder.size);

    return FolderModel(
      name: path.basename(directory.path),
      subFolders: subFolders,
      files: files,
      size: folderSize,
    );
  }

  bool _shouldIncludeEntity(String entityPath, String? filter) {
    return filter == null || path.basename(entityPath).contains(filter);
  }
}
