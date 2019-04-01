import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/screens/movie_list.dart';
import 'package:movie_catalog/services/movie_service.dart';
import 'package:movie_catalog/services/storage_service.dart';

class SuggestionsScreen extends StatefulWidget {
  @override
  _SuggestionsScreenState createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  MovieService _movieService;
  StorageService _storageService;
  Future<List<Movie>> _suggestedMovies;
  List<Movie> _likedMovies;
  Movie _selectedMovie;

  @override
  void initState() {
    super.initState();
    _movieService = new MovieService();
    _storageService = new StorageService();
    _suggestedMovies = getSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Suggestions'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text(
                            'Suggestions are based on the movies in your library.'),
                      );
                    });
              },
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
          child: Column(
            children: <Widget>[
              Container(
                child: Expanded(
                  child: FutureBuilder<List<Movie>>(
                    future: _suggestedMovies,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        default:
                          if (snapshot.hasError) {
                            // Worst solution ever
                            if (snapshot.error.toString() ==
                                'Bad state: No element') {
                              return Center(
                                  child: Text(
                                      'No suggestions available.\nClick the help icon for more info.'));
                            }
                            return Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.error),
                                  Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 3.0)),
                                  Text(
                                      'Could not reach the server. Try again later.'),
                                ],
                              ),
                            );
                          } else
                            return _createListView(context, snapshot);
                      }
                    },
                  ),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: _likedMovies?.isNotEmpty ??
                false || _likedMovies?.length != 1 ??
                false
            ? FloatingActionButton(
                backgroundColor: Theme.of(context).primaryColorDark,
                child: Icon(
                  Icons.refresh,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _suggestedMovies = getSuggestions();
                  });
                },
              )
            : null);
  }

  Future<List<Movie>> getSuggestions() async {
    _likedMovies = await _storageService.readFile();
    _likedMovies?.shuffle();
    _selectedMovie = _likedMovies?.first;
    return await _movieService.fetchSuggestions(
        http.Client(), _selectedMovie.id);
  }

  Widget _createListView(
      BuildContext context, AsyncSnapshot<List<Movie>> snapshot) {
    List<Movie> movies = snapshot.data;
    return Column(
      children: <Widget>[
        Row(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 12.0),
          ),
          Text('Based on'),
          Padding(
            padding: EdgeInsets.only(left: 5.0),
          ),
          Chip(
            label: Text(_selectedMovie?.title ?? '*'),
            backgroundColor: Theme.of(context).primaryColorLight,
          ),
        ]),
        Expanded(
          child: MovieList(movies, 'd'),
        )
      ],
    );
  }
}
