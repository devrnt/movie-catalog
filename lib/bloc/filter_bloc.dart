import 'dart:async';

import 'package:meta/meta.dart';
import 'package:movie_catalog/services/movie_service.dart';
import 'package:rxdart/rxdart.dart';

import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/models/movie.dart';

import 'package:http/http.dart' as http;

/// Fetches the movie details for the passed [movie]
class FilterBloc extends BlocBase {
  List<Movie> _filteredMovies;

  BehaviorSubject<List<Movie>> _filteredMoviesController =
      new BehaviorSubject();
  Stream<List<Movie>> get filteredMoviesOut => _filteredMoviesController.stream;

  final MovieService _movieService = new MovieService();

  final int currentPage;
  final String genre;
  final String quality;
  final String rating;

  FilterBloc({
    @required this.currentPage,
    @required this.genre,
    @required this.quality,
    @required this.rating,
  }) {
    _getFilterResults();
  }

  void _getFilterResults() async {
    _filteredMovies = await _movieService.fetchMoviesByConfig(
        http.Client(), currentPage, genre, quality, rating);

    _filteredMoviesController.sink.add(_filteredMovies);
  }

  @override
  void dispose() async {
    // Discards all data on the stream, but signals when it's done or an error occurred.
    await _filteredMoviesController.drain();
    _filteredMoviesController.close();
  }
}
