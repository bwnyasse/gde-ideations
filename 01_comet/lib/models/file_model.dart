import 'package:ansicolor/ansicolor.dart';
import 'package:intl/intl.dart';

class FileModel {
  final String name;
  final int size;
  final bool showSize;
  final DateTime modifiedTime;
  final bool showDate;

  FileModel({
    required this.name,
    required this.size,
    required this.showSize,
    required this.modifiedTime,
    required this.showDate,
  });

  @override
  String toString() {
    final pen = AnsiPen()..blue();
    final modifiedTimePen = AnsiPen()..yellow();
    final modifiedTimeString = showDate
        ? '(${modifiedTimePen(_getFormattedModifiedTime(modifiedTime))})'
        : '';
    return showSize
        ? '[${pen(_getHumanReadableSize(size))}] $name $modifiedTimeString'
        : '$name $modifiedTimeString';
  }

  String _getHumanReadableSize(int bytes) {
    final units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    int i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < units.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(2)} ${units[i]}';
  }

  String _getFormattedModifiedTime(DateTime modifiedTime) {
    final now = DateTime.now();
    final difference = now.difference(modifiedTime);

    if (difference.inDays >= 1) {
      return DateFormat('yyyy-MM-dd').format(modifiedTime);
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inSeconds}s ago';
    }
  }
}