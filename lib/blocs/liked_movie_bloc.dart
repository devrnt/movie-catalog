import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'package:movie_catalog/blocs/bloc_base.dart';
import 'package:movie_catalog/models/models.dart';

/// Checks if a movie is already liked or not
/// This could in fact be moved to the `liked bloc` class
class LikedMovieBloc extends BlocBase {
  final Movie movie;

  ///  Returns `true` if a movie is liked
  final BehaviorSubject<bool> _isLikedController = new BehaviorSubject();
  Stream<bool> get isLikedOut => _isLikedController.stream;

  /// Returns all liked movies
  final PublishSubject<List<Movie>> _likedMoviesController =
      new PublishSubject();
  Sink<List<Movie>> get likedMovieIn => _likedMoviesController.sink;

  LikedMovieBloc({@required this.movie}) {
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
