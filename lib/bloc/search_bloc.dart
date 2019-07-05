import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

import 'package:movie_catalog/bloc/bloc_base.dart';
import 'package:movie_catalog/services/movie_service.dart';
import 'package:movie_catalog/models/models.dart';

class SearchBloc extends BlocBase {
  /// The [BehaviorSubject] is a [StreamController]
  /// The controller has the search results
  BehaviorSubject<List<Movie>> _searchResultsController = new BehaviorSubject();

  /// The [Sink] is the input for the [_searchResultsController]
  Sink<List<Movie>> get searchResultsIn => _searchResultsController.sink;

  /// The [Stream] is the output for the [_suggestionsController]
  Stream<List<Movie>> get searchResultsOut => _searchResultsController.stream;

  /// The [BehaviorSubject] is a [StreamController]
  /// The controller has the input for the search query
  BehaviorSubject<String> _searchTextController = new BehaviorSubject();

  /// The [Sink] is the input for the [_searchTextController]
  Sink<String> get searchTextIn => _searchTextController.sink;

  /// The [BehaviorSubject] is a [StreamController]
  /// The controller has the flag if the searchbloc is fetching movies
  BehaviorSubject<bool> _loadingController = new BehaviorSubject();

  /// The [Sink] is the output for the [_loadingController]
  Stream<bool> get loadingOut => _loadingController.stream;

  /// Keeps track of the search results
  List<Movie> _searchResults = [];

  final MovieService _movieService = new MovieService();

  /// Keeps track if there is already a handle request in progress to protect from to many requests
  bool loading = false;

  SearchBloc() {
    _searchTextController.stream.listen(_handleSearchQuery);
  }

  void dispose() {
    _searchResultsController.close();
    _searchTextController.close();
    _loadingController.close();
  }

  void _handleSearchQuery(String searchQuery) async {
    if (searchQuery.isNotEmpty) {
      _loadingController.sink.add(true);
      try {
        List<Movie> fetchedMovies = await _movieService.fetchMoviesByQuery(
            http.Client(), searchQuery, 1);

        _searchResults = UnmodifiableListView<Movie>(fetchedMovies);
        searchResultsIn.add(_searchResults);
      } catch (exception) {
        _searchResultsController.addError(exception);
      }

      _loadingController.sink.add(false);
    } else {
      _searchResults = UnmodifiableListView<Movie>([]);
      searchResultsIn.add(_searchResults);
    }
  }
}
