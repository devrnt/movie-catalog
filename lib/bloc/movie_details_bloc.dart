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
    _movieDetailsController.sink.add(this.movie);
    _getMovieDetails();
  }

  void _getMovieDetails() async {
    Movie updatedMovie = await _movieService.fetchMovieById(http.Client(), movie.id);

    _movieDetailsController.sink.add(updatedMovie);
  }

  @override
  void dispose() {
    _movieDetailsController.close();
  }
}
