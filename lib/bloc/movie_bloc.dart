import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/services/movie_service.dart';
import 'package:movie_catalog/models/movie.dart';

class MovieBloc extends BlocBase {
  /// Keeps track of the page to fetch the latest movies from the api
  int _latestMoviesPage = 1;

  /// Keeps track of the page to fetch the popularst movies from the api
  int _popularMoviesPage = 1;

  // Latest movies
  /// The [BehaviorSubject] is a [StreamController]
  /// The controller has the latest 50 fetched movies
  BehaviorSubject<List<Movie>> _latestMoviesController = new BehaviorSubject();

  /// The [Sink] is the input for the [_latestMoviesController]
  Sink<List<Movie>> get latestMoviesIn => _latestMoviesController.sink;

  /// The [Stream] is the output for the [_latestMoviesController]
  Stream<List<Movie>> get latestMoviesOut => _latestMoviesController.stream;

  // Popular movies
  /// The [BehaviorSubject] is a [StreamController]
  /// The controller has the popularst 50 fetched movies
  BehaviorSubject<List<Movie>> _popularstMoviesController =
      new BehaviorSubject();

  /// The [Sink] is the input for the [_popularstMoviesController]
  Sink<List<Movie>> get popularstMoviesIn => _popularstMoviesController.sink;

  /// The [Stream] is the output for the [_popularstMoviesController]
  Stream<List<Movie>> get popularMoviesOut => _popularstMoviesController.stream;

  /// [PublishSubject] is the same as a [StreamController] but from the rxDart library
  PublishSubject<MovieType> _fetchNextPageController = new PublishSubject();

  /// The [Sink] is the input to increment the [_latestMoviesPage] or [_popularMoviesPage]
  Sink<MovieType> get fetchNextPageIn => _fetchNextPageController.sink;

  /// Keeps track of the latest movies
  List<Movie> _latestMovies = [];

  /// Keeps track of the popularst movies
  List<Movie> _popularMovies = [];

  final MovieService _movieService = new MovieService();

  /// Keeps track if there is already a handle request in progress to protect from to many requests
  bool loading = false;

  MovieBloc() {
    getMovies(MovieType.latest);
    getMovies(MovieType.popular);

    _fetchNextPageController.stream.listen(_handleNextPage);
  }

  void dispose() {
    _latestMoviesController.close();
    _popularstMoviesController.close();
    _fetchNextPageController.close();
  }

  void getMovies(MovieType movieType) async {
    List<Movie> fetchedMovies;
    loading = true;

    switch (movieType) {
      case MovieType.latest:
        try {
          fetchedMovies = await _movieService.fetchLatestMovies(
              http.Client(), _latestMoviesPage);
          _latestMovies.addAll(UnmodifiableListView<Movie>(fetchedMovies));

          latestMoviesIn.add(_latestMovies);
        } catch (exception) {
          _latestMoviesController.addError(exception);
        }
        break;
      case MovieType.popular:
        try {
          fetchedMovies = await _movieService.fetchPopularMovies(
              http.Client(), _popularMoviesPage);
          _popularMovies.addAll(UnmodifiableListView<Movie>(fetchedMovies));

          popularstMoviesIn.add(_popularMovies);
        } catch (exception) {
          _popularstMoviesController.addError(exception);
        }
        break;
      default:
    }
    loading = false;
  }

  void _handleNextPage(MovieType movieType) {
    if (!loading) {
      switch (movieType) {
        case MovieType.latest:
          _latestMoviesPage++;
          break;
        case MovieType.popular:
          _popularMoviesPage++;
          break;
      }

      getMovies(movieType);
    }
  }
}

enum MovieType { latest, popular }
