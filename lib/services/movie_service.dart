import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:movie_catalog/data/dummy_data.dart';
import 'package:movie_catalog/models/movie.dart';

const url = 'https://yts.am/api/v2/list_movies.json';

class MovieService {
  List<Movie> listOfMovies;
  MovieService() {
    listOfMovies = movies;
  }

  // Fetch all the movies
  // Keep the order of the API
  Future<List<Movie>> fetchAllMovies(http.Client client) async {
    final response = await client.get(url);

    if (response.statusCode == 200) {
      // Use the compute function to run parsePhotos in a separate isolate
      return parseMovies(response.body);
    } else {
      throw Exception(
          'Failed to load movies: Check if the api ${url} is still online. If not the case check if the mapping is still correct.');
    }
  }

  // Convert the list of movies from API to list
  List<Movie> parseMovies(String responseBody) {
    final movies = json.decode(responseBody)['data']['movies'];
    final parsed = movies.cast<Map<String, dynamic>>();
    return parsed.map<Movie>((json) => Movie.fromJson(json)).toList();
  }

  Movie getMovie(int id) {
    return listOfMovies.where((movie) => movie.id == id).first;
  }
}
