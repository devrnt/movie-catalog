import 'dart:async';
import 'dart:collection';

import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/services/storage_service.dart';

import 'package:rxdart/rxdart.dart';

class LikedBloc implements BlocBase {
  ///
  /// Unique list of all liked movies
  ///
  List<Movie> _likedMovies = new List();
  final StorageService _storageService = new StorageService();

  // ##########  STREAMS  ##############
  ///
  /// Interface that allows to add a new favorite movie
  ///
  BehaviorSubject<Movie> _addLikedMovieController =
      new BehaviorSubject<Movie>();
  Sink<Movie> get addLikedSink => _addLikedMovieController.sink;

  ///
  /// Interface that allows to remove a movie from the list of liked movies
  ///
  BehaviorSubject<Movie> _removeLikedMovieController =
      new BehaviorSubject<Movie>();
  Sink<Movie> get removeLikedSink => _removeLikedMovieController.sink;

  ///
  /// Interface that allows to get the total number of favorites
  ///
  // BehaviorSubject<int> _favoriteTotalController = new BehaviorSubject<int>(seedValue: 0);
  // Sink<int> get _inTotalFavorites => _favoriteTotalController.sink;
  // Stream<int> get outTotalFavorites => _favoriteTotalController.stream;

  ///
  /// Interface that allows to get the list of all favorite movies
  ///
  BehaviorSubject<List<Movie>> _likedMoviesController =
      new BehaviorSubject<List<Movie>>()..add([]);
  Sink<List<Movie>> get likedMoviesSink => _likedMoviesController.sink;
  Stream<List<Movie>> get likedMoviesStream => _likedMoviesController.stream;

  ///
  /// Constructor
  ///
  LikedBloc() {
    _addLikedMovieController.listen(_handleAddLiked);
    _removeLikedMovieController.listen(_handleRemoveLiked);
    getLikedMovies();
  }

  void getLikedMovies() async {
    _likedMovies = await _storageService.readFile();

    likedMoviesSink.add(UnmodifiableListView(_likedMovies));
  }

  void dispose() {
    _addLikedMovieController.close();
    _removeLikedMovieController.close();
    _likedMoviesController.close();
  }

  // ############# HANDLING  #####################

  void _handleAddLiked(Movie movie) async {
    print(movie.title);
    await _storageService.writeToFile(movie);

    getLikedMovies();
  }

  void _handleRemoveLiked(Movie movie) async {
    print('Remove ${movie.title}');
    await _storageService.removeFromFile(movie);

    getLikedMovies();
  }
}
