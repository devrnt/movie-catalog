import 'package:flutter/material.dart';
import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/screens/movie_details_screen.dart';

import 'package:movie_catalog/services/movie_service.dart';

import 'package:http/http.dart' as http;

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
        title: Text('Search movies'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 10.0),
        child: Column(
          children: <Widget>[
            _buildSearchInput(),
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
                              if (snapshot.hasError)
                                return Text('Error: ${snapshot.error}');
                              else
                                return _createListView(context, snapshot);
                          }
                          // if (snapshot.hasError) print(snapshot.error);

                          // return snapshot.hasData
                          //     ? _createListView(
                          //         context,
                          //         snapshot,
                          //       )
                          //     : Center(child: CircularProgressIndicator());
                        },
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget _createListView(BuildContext context, AsyncSnapshot snapshot) {
    List<Movie> movies = snapshot.data;
    return movies.length != 0
        ? ListView.builder(
            itemCount: movies.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    subtitle: Text(
                      movies[index].year.toString(),
                      style: TextStyle(color: Colors.grey),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
                    leading: Image.network(
                      movies[index].coverImageMedium,
                      height: 65.0,
                    ),
                    title: Text(movies[index].title),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetails(
                                movie: movies[index],
                              ),
                        ),
                      );
                    },
                  ),
                  Divider(
                    height: 2.0,
                  ),
                ],
              );
            },
          )
        : Center(
            child: Text('No search results'),
          );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: EdgeInsets.only(bottom: 7.0),
      child: TextField(
        autofocus: true,
        controller: _searchQueryController,
        decoration: new InputDecoration(
          hintText: 'Harry Potter, Batman...',
          prefixIcon: new Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
            child: new Icon(Icons.search),
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