import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart'
    if (dart.library.html) 'src/stub/path_provider.dart';

class HiveService {
  const HiveService._();

  static var boxData = <String, Map<dynamic, dynamic>>{};

  static Future<Map<String, Map<dynamic, dynamic>>> getBoxData() async {
    final boxData = <String, Map<dynamic, dynamic>>{};
    if (!kDebugMode) {
      return boxData;
    }

    final boxNames = await _getBoxNames();

    for (final boxName in boxNames) {
      try {
        final box = await Hive.openBox(boxName);
        boxData[boxName] = box.toMap();
      } catch (e) {
        debugPrint('Error opening or reading box "$boxName": $e');
      }
    }
    HiveService.boxData = boxData;
    return boxData;
  }

  static Future<List<String>> _getBoxNames() async {
    final appDir = await getApplicationDocumentsDirectory();

    final directory = Directory(appDir.path);
    final List<FileSystemEntity> entities = await directory.list().toList();

    final List<String> boxNames =
        entities
            .where((file) => file.path.endsWith('.hive'))
            .map((file) => file.path.split('/').last.split('.hive').first)
            .toList();

    return boxNames;
  }
}
