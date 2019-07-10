import 'dart:async';

import 'package:movie_catalog/models/models.dart';

import 'package:http/http.dart' as http;

abstract class IMovieService {
  Future<List<Movie>> fetchLatestMovies(http.Client client, int currentPage);
  Future<List<Movie>> fetchPopularMovies(http.Client client, int currentPage);
  Future<List<Movie>> fetchMoviesByQuery(
      http.Client client, String query, int currentPage);
  Future<List<Movie>> fetchMoviesByConfig(http.Client client, int currentPage,
      String genre, String quality, String rating);
  Future<Movie> fetchMovieById(http.Client client, int id);
  Future<List<Movie>> fetchSuggestions(http.Client client, int movieId);
  Future<List<Movie>> fetchAllSuggestions(
      http.Client client, List<int> movieIds);
}
