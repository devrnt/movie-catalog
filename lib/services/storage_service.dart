import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

import 'package:movie_catalog/models/movie.dart';

class StorageService {
  final String fileName = 'likedMovies.json';

  Map<String, dynamic> fileContent;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<List<Movie>> readFile() async {
    try {
      final file = await _localFile;
      List listOfMaps = json.decode(await file.readAsString());

      List movies = listOfMaps.map((map) => Movie.fromJson(map)).toList();
      return movies;
    } catch (e) {
      print(e);
      return new List();
    }
  }

  Future<File> writeToFile(Movie movie) async {
    final file = await _localFile;
    List movies = await readFile();
    movies.add(movie);
    return file.writeAsString(json.encode(movies));
  }

  Future<File> removeFromFile(Movie movie) async {
    final file = await _localFile;
    List movies = await readFile();
    movies.removeWhere((movieFromStorage) => movieFromStorage.id == movie.id);
    return file.writeAsString(json.encode(movies));
  }

  Future<bool> liked(Movie movie) async {
    List<Movie> movies = await readFile();
    bool flag =
        movies.any((movieFromStorage) => movieFromStorage.id == movie.id);
    return flag;
  }

  Future<String> get downloadsPath async {
    final directoryTemp = await getExternalStorageDirectory();
    return '${directoryTemp.path}/Download';
  }
}
