import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract class IStorageService<T> {
  final String fileName;

  IStorageService(this.fileName);

  Future<File> get localFile async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/$fileName');
  }

  Future<String> get downloadsPath async {
    return '/storage/emulated/0/Download/';
  }

  Future<T> readFile();
}
