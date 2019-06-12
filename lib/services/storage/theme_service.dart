import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:movie_catalog/services/storage/istorage_service.dart';
import 'package:path_provider/path_provider.dart';

class ThemeService extends IStorageService<bool> {
  ThemeService() : super('selectedTheme.json');

  @override
  Future<bool> readFile() async {
    try {
      final file = await localFile;
      bool flag = json.decode(await file.readAsString()) as bool;

      return flag;
    } catch (e) {
      // Probably a FileSystemException exception
      print(e);
      return false;
    }
  }

  Future<File> writeToFile(bool flag) async {
    final file = await localFile;
    return file.writeAsString(json.encode(flag));
  }

  Future<String> get downloadsPath async {
    final directoryTemp = await getExternalStorageDirectory();
    return '${directoryTemp.path}/Download';
  }
}
