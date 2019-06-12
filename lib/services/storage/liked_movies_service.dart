import 'dart:convert';
import 'dart:io';
import 'package:movie_catalog/models/models.dart';
import 'package:movie_catalog/services/storage/istorage_service.dart';

class LikedMoviesService extends IStorageService<List<Movie>> {
  LikedMoviesService() : super('likedMovies.json');

  @override
  Future<List<Movie>> readFile() async {
    try {
      final file = await localFile;
      List listOfMaps = json.decode(await file.readAsString());

      List movies = listOfMaps.map((map) => Movie.fromJson(map)).toList();
      return movies;
    } on FileSystemException catch (_) {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<File> writeToFile(Movie movie) async {
    final file = await localFile;
    List<Movie> movies = await readFile();
    movies.add(movie);
    return file.writeAsString(json.encode(movies));
  }

  Future<File> removeFromFile(Movie movie) async {
    final file = await localFile;
    List<Movie> movies = await readFile();
    movies.removeWhere((movieFromStorage) => movieFromStorage.id == movie.id);
    return file.writeAsString(json.encode(movies));
  }

  Future<bool> liked(Movie movie) async {
    List<Movie> movies = await readFile();
    bool flag =
        movies.any((movieFromStorage) => movieFromStorage.id == movie.id);
    return flag;
  }
}
