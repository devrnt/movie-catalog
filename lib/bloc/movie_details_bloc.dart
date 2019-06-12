import 'dart:async';

import 'package:meta/meta.dart';
import 'package:movie_catalog/services/movie_service.dart';
import 'package:rxdart/rxdart.dart';

import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/models/movie.dart';

import 'package:http/http.dart' as http;

/// Fetches the movie details for the passed [movie]
class MovieDetailsBloc extends BlocBase {
  Movie movie;

  BehaviorSubject<Movie> _movieDetailsController = new BehaviorSubject();
  Stream<Movie> get movieDetailsOut => _movieDetailsController.stream;

  final MovieService _movieService = new MovieService();

  MovieDetailsBloc({@required this.movie}) {
    movie = movie;
    _getMovieDetails();
  }

  void _getMovieDetails() async {
    movie =
        await _movieService.fetchMovieById(http.Client(), movie.id);

    _movieDetailsController.sink.add(movie);
  }

  @override
  void dispose() async {
    // Discards all data on the stream, but signals when it's done or an error occurred.
    await _movieDetailsController.drain();
    _movieDetailsController.close();
  }
}
