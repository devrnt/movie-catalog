import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

class ThemeService {
  final String fileName = 'selectedTheme.json';

  Map<String, bool> fileContent;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<bool> readFile() async {
    try {
      final file = await _localFile;
      bool flag = json.decode(await file.readAsString()) as bool;

      return flag;
    } catch (e) {
      // Probably a FileSystemException exception
      print(e);
      return false;
    }
  }

  Future<File> writeToFile(bool flag) async {
    final file = await _localFile;
    return file.writeAsString(json.encode(flag));
  }

  Future<String> get downloadsPath async {
    final directoryTemp = await getExternalStorageDirectory();
    return '${directoryTemp.path}/Download';
  }
}
