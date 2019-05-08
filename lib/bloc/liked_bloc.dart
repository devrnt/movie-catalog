import 'dart:async';
import 'dart:collection';

import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/services/storage_service.dart';

import 'package:rxdart/rxdart.dart';

class LikedBloc implements BlocBase {
  /// Keeps track of the liked movies
  List<Movie> _likedMovies = new List();

  /// The [PublishSubject] is a [StreamController] but fom the rxDart library
  PublishSubject<Movie> _addLikedMovieController = new PublishSubject();

  /// The [Sink] is the input to add a movie to the [_likedMovies]
  Sink<Movie> get addLikedIn => _addLikedMovieController.sink;

  /// The [PublishSubject] is a [StreamController] but fom the rxDart library
  PublishSubject<Movie> _removeLikedMovieController = new PublishSubject();

  /// The [Sink] is the input to remove a movie to the [_likedMovies]
  Sink<Movie> get removeLikedIn => _removeLikedMovieController.sink;

  /// The [BehaviorSubject] is a [StreamController]
  /// The controller has the liked movies of the user
  BehaviorSubject<List<Movie>> _likedMoviesController = new BehaviorSubject();

  /// The [Sink] is the input for the [_likedMoviesController]
  Sink<List<Movie>> get likedMoviesIn => _likedMoviesController.sink;

  /// The [Stream] is the output for the [_likedMoviesController]
  Stream<List<Movie>> get likedMoviesOut => _likedMoviesController.stream;

  final StorageService _storageService = new StorageService();

  LikedBloc() {
    getLikedMovies();

    _addLikedMovieController.listen(_handleAddLiked);
    _removeLikedMovieController.listen(_handleRemoveLiked);
  }

  void dispose() {
    _addLikedMovieController.close();
    _removeLikedMovieController.close();
    _likedMoviesController.close();
  }

  void getLikedMovies() async {
    _likedMovies = await _storageService.readFile();

    likedMoviesIn.add(UnmodifiableListView(_likedMovies));
  }

  void _handleAddLiked(Movie movie) async {
    await _storageService.writeToFile(movie);

    getLikedMovies();
  }

  void _handleRemoveLiked(Movie movie) async {
    await _storageService.removeFromFile(movie);

    getLikedMovies();
  }
}
