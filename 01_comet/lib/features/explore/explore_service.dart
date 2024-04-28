import 'dart:io';

import 'package:comet/features/explore/explore_model.dart';
import 'package:path/path.dart' as path;

class ExploreService {
  Future<FolderModel> exploreFileSystem({
    int level = 5,
    String? pattern,
    bool dirOnly = false,
    bool showSize = false,
    bool showDate = false,
    bool showLines = false,
  }) async {
    final rootDir = Directory.current;
    return _exploreDirectory(
        rootDir, 0, level, pattern, dirOnly, showSize, showDate, showLines);
  }

  Future<FolderModel> _exploreDirectory(
    Directory directory,
    int currentDepth,
    int level,
    String? pattern,
    bool dirOnly,
    bool showSize,
    bool showDate,
    bool showLines,
  ) async {
    final subFolders = <FolderModel>[];
    final files = <FileModel>[];

    for (final entity in directory.listSync()) {
      if (entity is Directory) {
        if (_shouldIncludeEntity(
          entity,
          pattern,
        )) {
          if (currentDepth < level) {
            subFolders.add(
              await _exploreDirectory(
                entity,
                currentDepth + 1,
                level,
                pattern,
                dirOnly,
                showSize,
                showDate,
                showLines,
              ),
            );
          } else {
            subFolders.add(
              FolderModel(
                name: path.basename(entity.path),
                subFolders: [],
                files: [],
              ),
            );
          }
        }
      } else if (entity is File && !dirOnly) {
        if (_shouldIncludeEntity(
          entity,
          pattern,
        )) {
          final lines = await entity.readAsLines();
          final content = lines.length > 100 ? await entity.readAsString() : "";
          final fileSize = showSize ? await entity.length() : 0;

          files.add(
            FileModel(
              name: path.basename(entity.path),
              size: fileSize,
              showSize: showSize,
              showDate: showDate,
              modifiedTime: entity.lastModifiedSync(),
              showLines: showLines,
              countLines: lines.length,
              contentIf100Lines: content,
            ),
          );
        }
      }
    }

    return FolderModel(
      name: path.basename(directory.path),
      subFolders: subFolders,
      files: files,
    );
  }

  bool _shouldIncludeEntity(FileSystemEntity entity, String? pattern) {
    if (pattern == null || entity is Directory) {
      return true;
    }

    if (pattern.contains('*')) {
      // Handle wildcard pattern
      final regex = RegExp(r'^' + pattern.replaceAll('*', r'.*') + r'$');
      return regex.hasMatch(entity.path);
    } else {
      // Handle regular expression pattern
      return RegExp(pattern).hasMatch(entity.path);
    }
  }

  Future<String> readProjectContents({
    bool readLib = false,
    bool readBin = false,
    bool readPubspec = false,
    bool readReadme = false,
  }) async {
    final projectDir = Directory.current;
    final libDir = Directory(path.join(projectDir.path, 'lib'));
    final binDir = Directory(path.join(projectDir.path, 'bin'));
    final pubspecFile = File(path.join(projectDir.path, 'pubspec.yaml'));
    final readmeFile = File(path.join(projectDir.path, 'README.md'));

    // Check if the project has a pubspec.yaml file
    if (!await pubspecFile.exists()) {
      return 'This does not appear to be a Dart or Flutter project.';
    }

    final sb = StringBuffer();

    if (readLib && await libDir.exists()) {
      await _readDirectory(libDir, sb, projectDir.path);
    }

    if (readBin && await binDir.exists()) {
      await _readDirectory(binDir, sb, projectDir.path);
    }

    if (readPubspec) {
      sb.writeln('---------------- Below the contents of pubspec.yaml :');
      sb.writeln(await pubspecFile.readAsString());
      sb.writeln();
    }

    if (readReadme && await readmeFile.exists()) {
      sb.writeln('---------------- Below the contents of README.md :');
      sb.writeln(await readmeFile.readAsString());
      sb.writeln();
    }

    return sb.toString();
  }

  Future<void> _readDirectory(
      Directory directory, StringBuffer sb, String projectDir) async {
    for (final entity in await directory.list().toList()) {
      switch (entity) {
        case final directory when directory is Directory:
          await _readDirectory(directory, sb, projectDir);
        case final file when file is File && file.parent.path.endsWith('.dart'):
          final relativePath = path.relative(entity.path, from: projectDir);
          sb.writeln(
              '---------------- Below the contents of the file $relativePath :');
          sb.writeln(await file.readAsString());
          sb.writeln();
          break;
      }
    }
  }
}
