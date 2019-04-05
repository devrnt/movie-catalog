import 'dart:async';

import 'package:flutter/material.dart';

import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/services/movie_service.dart';
import 'package:movie_catalog/services/storage_service.dart';

import 'package:http/http.dart' as http;
import 'package:movie_catalog/widgets/movie_card_design.dart';

class MovieList extends StatefulWidget {
  final StorageService _storageService = new StorageService();
  final List<Movie> movies;
  final String type;
  // config used for passing the filter config
  final dynamic config;

  MovieList(this.movies, this.type, [this.config]) {
    print('Received movies: ${this.movies?.length}');
    // if (type == 'liked') {
    //   print('old ${movies?.length}');
    //   _fetchSavedMovies()
    //       .then((movies) => print(movies.length.toString() + '\n======'));
    //   print('moviegrid constructor is called $type');
    //   if (type == 'liked') {
    //     print('true');
    //     createState().mounted;
    //   }
    // }
  }

  Future<List<Movie>> _fetchSavedMovies() async {
    List<Movie> movies = await _storageService.readFile();
    return movies;
  }

  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  MovieService _movieService;
  ScrollController _scrollController;

  int currentPageLatest = 2;
  int currentPagePopular = 2;
  int currentPageConfig = 2;

  @override
  void initState() {
    super.initState();
    _movieService = new MovieService();

    _scrollController = new ScrollController();
    //_scrollController.addListener(_scrollListener);
  }

  @override
  void deactivate() {
    _scrollController.removeListener(() => _scrollController);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return widget.movies.length > 0
        ? ListView.builder(
            padding: EdgeInsets.fromLTRB(0.0, 12.0, 2.0, 0.0),
            itemCount: widget.movies.length,
            itemBuilder: (BuildContext context, int index) {
              return new Column(
                children: <Widget>[
                  MovieCardDesign(
                    movie: widget.movies[index],
                  ),
                ],
              );
            },
          )
        : Center(
            child: widget.type != 'liked'
                ? Text('Your library is empty')
                : Text('Your shelf is empty'));
  }

// TODO: remove not used methods
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (widget.type == 'latest') {
        _movieService
            .fetchLatestMovies(http.Client(), currentPageLatest)
            .then((newMovies) {
          setState(() {
            widget.movies.addAll(newMovies);
          });
          currentPageLatest++;
        });
      }
      if (widget.type == 'popular') {
        _movieService
            .fetchPopularMovies(http.Client(), currentPagePopular)
            .then((newMovies) {
          setState(() {
            widget.movies.addAll(newMovies);
          });
          currentPagePopular++;
        });
      }
      if (widget.type == 'config') {
        _movieService
            .fetchMoviesByConfig(
                http.Client(),
                currentPageConfig,
                widget.config['genre'],
                widget.config['quality'],
                widget.config['rating'])
            .then((newMovies) {
          setState(() {
            widget.movies.addAll(newMovies);
          });
          currentPageConfig++;
        });
      }
    }
  }
}
