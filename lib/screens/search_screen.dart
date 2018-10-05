import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/screens/movie_list.dart';

import 'package:movie_catalog/services/movie_service.dart';

import 'package:movie_catalog/screens/filter_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  MovieService _movieService;

  TextEditingController _searchQueryController = new TextEditingController();

  String _searchText;

  @override
  void initState() {
    super.initState();
    _movieService = new MovieService();
    _searchText = '';
    _searchQueryController.addListener(_textInputListener);
  }

  @override
  void dispose() {
    _searchQueryController.removeListener(_textInputListener);
    _searchQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchInput(),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FilterScreen(),
                ),
              );
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              child: _searchText.isEmpty
                  ? Container(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                    )
                  : Expanded(
                      child: FutureBuilder<List<Movie>>(
                        future: _movieService.fetchMoviesByQuery(
                            http.Client(), _searchText, 1),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            default:
                              if (snapshot.hasError) {
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
                                return MovieList(snapshot.data, 'search');
                          }
                        },
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: TextField(
        autofocus: true,
        controller: _searchQueryController,
        decoration: new InputDecoration(
          border: InputBorder.none,
          hintText: 'Title, year...',
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
            child: Icon(
              Icons.search,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  void _textInputListener() {
    if (_searchQueryController.text.isEmpty) {
      print('event listerner called EMPTY');
      setState(() {
        _searchText = '';
      });
    } else {
      print(_searchQueryController.text != _searchText);
      if (_searchQueryController.text != _searchText) {
        setState(() {
          print('event listerner called NOT EMPTY');
          _searchText = _searchQueryController.text;
        });
      } else {
        print('setstat not called');
      }
    }
  }
}
