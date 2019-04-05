import 'dart:async';
import 'dart:collection';

import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/services/storage_service.dart';
import 'package:rxdart/rxdart.dart';

import 'package:http/http.dart' as http;

import 'package:movie_catalog/services/movie_service.dart';
import 'package:movie_catalog/models/movie.dart';

class MovieBloc extends BlocBase {
  int latestPage = 1;
  int popularPage = 1;

  // Latest movies
  BehaviorSubject<List<Movie>> _latestMoviesController =
      BehaviorSubject<List<Movie>>();
  Sink<List<Movie>> get latestMoviesSink => _latestMoviesController.sink;
  Stream<List<Movie>> get latestMoviesStream => _latestMoviesController.stream;

  // Popular movies
  // TODO: figure out why this must be a replaySubject or Behviour
  // Does not work with a PublishSubject, must be ReplaySubject or Behviour
  BehaviorSubject<List<Movie>> _popularMoviesController =
      BehaviorSubject<List<Movie>>();
  Sink<List<Movie>> get popularMoviesSink => _popularMoviesController.sink;
  Stream<List<Movie>> get popularMoviesStream =>
      _popularMoviesController.stream;

  // Saved movies
  BehaviorSubject<List<Movie>> _savedMoviesController =
      BehaviorSubject<List<Movie>>();
  Sink<List<Movie>> get savedMoviesSink => _savedMoviesController.sink;
  Stream<List<Movie>> get savedMoviesStream => _savedMoviesController.stream;

  //  Future<List<Movie>> _fetchSavedMovies() {
  //   return _storageService.readFile();
  // }

  // Used to update the page counter
  // Looks at the MovieType that is passed
  BehaviorSubject<MovieType> _fetchNextPage = BehaviorSubject<MovieType>();
  Sink<MovieType> get fetchNextPageSink => _fetchNextPage.sink;

  // Add new movie to saved movies list
  BehaviorSubject<Movie> _likeMovie = BehaviorSubject<Movie>();
  Sink<Movie> get likeMovieSink => _likeMovie.sink;

  // Keep track of the movies to pass to the publishSubject
  List<Movie> latestMovies = [];
  List<Movie> popularMovies = [];
  List<Movie> savedMovies = [];

  final MovieService _movieService = new MovieService();
  final StorageService _storageService = new StorageService();

  // Protection so the scroll notification won't spam the 'load more' method
  bool loading = false;

  MovieBloc() {
    getLatestMovies();
    getPopularMovies();
    getSavedMovies();
    _fetchNextPage.stream.listen(_handleLogic);
    _likeMovie.stream.listen(_handleLikeMovie);
  }

  void getSavedMovies() async {
    List<Movie> movies = await _storageService.readFile();

    savedMovies.addAll(UnmodifiableListView(movies));

    print(savedMovies.length);
    savedMoviesSink.add(savedMovies);
  }

  void getPopularMovies() async {
    loading = true;
    List<Movie> fetchedMovies =
        await _movieService.fetchPopularMovies(http.Client(), popularPage);

    popularMovies.addAll(UnmodifiableListView<Movie>(fetchedMovies));

    popularMoviesSink.add(popularMovies);
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
    _savedMoviesController.close();
    _fetchNextPage.close();
    _likeMovie.close();
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
          getPopularMovies();
          print('going to fetch pop movies');
          break;
        default:
        // Do nothing
      }
      print('SCROLLING JUST BY MYSELF');
    }
  }

  void _handleLikeMovie(Movie movie) async {
    _storageService.writeToFile(movie);

    List<Movie> movies = await _storageService.readFile();
    print(movies.length);

    savedMovies = movies;
    print(savedMovies.length);

    savedMoviesSink.add(savedMovies);
  }
}

enum MovieType { latest, popular }
