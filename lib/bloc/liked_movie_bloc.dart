import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/models/movie.dart';

import 'package:rxdart/rxdart.dart';
import 'dart:async';

class LikedMovieBloc extends BlocBase {
  final Movie movie;

  ///  Returns `true` if a movie is liked
  final BehaviorSubject<bool> _isLikedController = new BehaviorSubject<bool>();
  Stream<bool> get isLikedStream => _isLikedController.stream;

  /// Returns all liked movies
  final StreamController<List<Movie>> _likedMoviesController =
      new StreamController<List<Movie>>();
  Sink<List<Movie>> get likedMoviesSink => _likedMoviesController.sink;

  LikedMovieBloc({this.movie}) {
    // Listen to all liked movies
    _likedMoviesController.stream
        .map((likedMovies) =>
            likedMovies.any((Movie item) => item.id == movie.id))
        .listen((isLiked) => _isLikedController.add(isLiked));
  }

  @override
  void dispose() {
    _isLikedController.close();
    _likedMoviesController.close();
  }
}
