import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';

import 'package:http/http.dart' as http;

import 'package:movie_catalog/services/movie_service.dart';
import 'package:movie_catalog/models/movie.dart';

class MovieBloc {
  int latestPage = 1;
  int popularPage = 1;

  // Latest movies
  PublishSubject<List<Movie>> _latestMoviesController =
      PublishSubject<List<Movie>>();
  Sink<List<Movie>> get latestMoviesSink => _latestMoviesController.sink;
  Stream<List<Movie>> get latestMoviesStream => _latestMoviesController.stream;

  // Popular movies
  PublishSubject<List<Movie>> _popularMoviesController =
      PublishSubject<List<Movie>>();
  Sink<List<Movie>> get popularMoviesSink => _latestMoviesController.sink;
  Stream<List<Movie>> get popularMoviesStream => _latestMoviesController.stream;

  // Used to update the page counter
  // Looks at the MovieType that is passed
  PublishSubject<MovieType> _fetchNextPage = PublishSubject<MovieType>();
  Sink<MovieType> get fetchNextPageSink => _fetchNextPage.sink;
  Stream<MovieType> get fetchNextPageStream => _fetchNextPage.stream;

  // Keep track of the movies to pass to the publishSubject
  List<Movie> latestMovies = [];
  List<Movie> popularMovies = [];

  final MovieService _movieService = new MovieService();

  // Protection so the scroll notification won't spam the 'load more' method
  bool loading = false;

  MovieBloc() {
    fetchNextPageStream.listen(_handleLogic);
  }

  void getPopularMovies() async {
    loading = true;

    List<Movie> fetchedMovies =
        await _movieService.fetchLatestMovies(http.Client(), popularPage);

    popularMovies.addAll(UnmodifiableListView<Movie>(fetchedMovies));

    latestMoviesSink.add(popularMovies);
    loading = false;
  }

  void getLatestMovies() async {
    loading = true;

    List<Movie> fetchedMovies =
        await _movieService.fetchLatestMovies(http.Client(), latestPage);

    latestMovies.addAll(UnmodifiableListView<Movie>(fetchedMovies));

    latestMoviesSink.add(latestMovies);
    loading = false;
  }

  void dispose() {
    _latestMoviesController.close();
    _popularMoviesController.close();
    _fetchNextPage.close();
  }

  void _handleLogic(MovieType movieType) {
    if (!loading) {
      print(movieType);
      print('-----------');
      switch (movieType) {
        case MovieType.latest:
          latestPage++;
          getLatestMovies();
          break;
        case MovieType.popular:
          popularPage++;
          break;
        default:
        // Do nothing
      }
      print('SCROLLING JUST BY MYSELF');
    }
  }
}

enum MovieType { latest, popular }

final bloc = new MovieBloc();
