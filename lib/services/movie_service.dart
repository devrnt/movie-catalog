import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:movie_catalog/services/imovie_service.dart';

import 'package:movie_catalog/models/movie.dart';

class MovieService implements IMovieService {
  final String apiUrl = 'https://yts.am/api/v2/list_movies.json';
  final String apiUrlDetails = 'https://yts.am/api/v2/movie_details.json';
  final String apiUrlSuggestions =
      'https://yts.am/api/v2/movie_suggestions.json';

  // Fetch all the movies, the order of the api is kept
  Future<List<Movie>> fetchLatestMovies(
      http.Client client, int currentPage) async {
    // the defaut limit in the API is set to 20
    String fetchUrl = apiUrl + '?limit=50' + '&page=' + currentPage.toString();

    // print('fetched link: ' + fetchUrl);
    final response = await client.get(fetchUrl);

    if (response.statusCode == 200) {
      // Use the compute function to run parsePhotos in a separate isolate
      return compute(parseMovies, response.body);
    } else {
      throw Exception('Failed to load movies: Check if the api' +
          fetchUrl +
          'is still online. If not the case check if the mapping is still correct.');
    }
  }

  Future<List<Movie>> fetchPopularMovies(
      http.Client client, int currentPage) async {
    String fetchUrl = apiUrl +
        '?limit=50' +
        '&sort_by=rating' +
        '&page=' +
        currentPage.toString();
    // print('fetched link: ' + fetchUrl);

    final response = await client.get(fetchUrl);

    if (response.statusCode == 200) {
      // Use the compute function to run parsePhotos in a separate isolate
      return compute(parseMovies, response.body);
    } else {
      throw Exception('Failed to load movies: Check if the api' +
          fetchUrl +
          'is still online. If not the case check if the mapping is still correct.');
    }
  }

  @override
  Future<List<Movie>> fetchMoviesByQuery(
      http.Client client, String query, int currentPage) async {
    String queryTerm = query.replaceAll(' ', '+');
    String fetchUrl = apiUrl +
        '?limit=50' +
        '&query_term=' +
        Uri.encodeFull(queryTerm) +
        '&sort_by=year&order_by=asc';
    // print('fetched link: ' + fetchUrl);

    final response = await client.get(fetchUrl);

    if (response.statusCode == 200) {
      // Use the compute function to run parsePhotos in a separate isolate
      return compute(parseMovies, response.body);
    } else {
      throw Exception('Failed to load movies: Check if the api' +
          fetchUrl +
          'is still online. If not the case check if the mapping is still correct.');
    }
  }

  @override
  Future<List<Movie>> fetchMoviesByConfig(http.Client client, int currentPage,
      String genre, String quality, String rating) async {
    String fetchUrl = apiUrl + '?limit=50' + '&page=$currentPage';

    if (genre.length > 0) fetchUrl += '&genre=$genre';
    if (quality.length > 0) fetchUrl += '&quality=$quality';
    if (rating.length > 0) fetchUrl += '&minimum_rating=$rating';

    final response = await client.get(fetchUrl);

    if (response.statusCode == 200) {
      // Use the compute function to run parsePhotos in a separate isolate
      return compute(parseMovies, response.body);
    } else {
      throw Exception('Failed to load movies: Check if the api' +
          fetchUrl +
          'is still online. If not the case check if the mapping is still correct.');
    }
  }

  @override
  Future<Movie> fetchMovieById(http.Client client, int id) async {
    String fetchUrl = apiUrlDetails + '?movie_id=$id';

    final response = await client.get(fetchUrl);

    if (response.statusCode == 200) {
      // Use the compute function to run parseMovies in a separate isolate
      return compute(parseMovie, response.body);
    } else {
      throw Exception('Failed to load movies: Check if the api' +
          fetchUrl +
          'is still online. If not the case check if the mapping is still correct.');
    }
  }

  @override
  Future<List<Movie>> fetchSuggestions(http.Client client, int movieId) async {
    fetchAllSuggestions(client, [1, 2, 3]);
    String fetchUrl = '$apiUrlSuggestions?movie_id=$movieId';
    print(fetchUrl);

    final response = await client.get(fetchUrl);

    if (response.statusCode == 200) {
      // Use the compute function to run parseMovies in a separate isolate
      return compute(parseMovies, response.body);
    } else {
      throw Exception('Failed to load movies: Check if the api' +
          fetchUrl +
          'is still online. If not the case check if the mapping is still correct.');
    }
  }

  @override
  Future<List<Movie>> fetchAllSuggestions(
      http.Client client, List<int> movieIds) async {
    List<String> allEndpoints = [];

    movieIds.forEach(
        (movieId) => allEndpoints.add('$apiUrlSuggestions?movie_id=$movieId'));

    List<Future> futures =
        allEndpoints.map((endpoint) => client.get(endpoint)).toList();

    List allResponses = await Future.wait(futures);

    List<Movie> movies = [];
    allResponses.forEach((response) {
      if (response.statusCode == 200) {
        // Use the compute function to run parseMovies in a separate isolate
        movies.addAll(parseMovies(response.body));
      } else {
        throw Exception('Failed to load movies: Check if the api' +
            // fetchUrl +
            'is still online. If not the case check if the mapping is still correct.');
      }
    });
    return movies;
  }
}

// THIS SHOULD BE A TOP LEVEL FUNCTION OTHEREWISE COMPUTE WILL GIVE ERRORS
// Convert the list of movies from API to list of movies
List<Movie> parseMovies(String responseBody) {
  // cut the useless data from the response body
  final checkIfMovies = json.decode(responseBody)['data']['movie_count'];
  var rightJson;
  if (checkIfMovies != 0) {
    rightJson = json.decode(responseBody)['data']['movies'];
  } else {
    rightJson = null;
  }
  if (rightJson != null) {
    final parsed = rightJson.cast<Map<String, dynamic>>();

    return parsed.map<Movie>((json) => new Movie.fromJson(json)).toList();
  } else {
    return new List();
  }
}

Movie parseMovie(String responseBody) {
  // cut the useless data from the response body
  var rightJson = json.decode(responseBody)['data']['movie'];

  if (rightJson != null) {
    Movie movie = Movie.fromJson(rightJson);
    return movie;
  } else {
    return null;
  }
}
