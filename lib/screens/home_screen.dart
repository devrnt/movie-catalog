import 'package:flutter/material.dart';
import 'package:movie_catalog/data/dummy_data.dart';

import 'package:movie_catalog/widgets/movie_card.dart';

import 'package:movie_catalog/models/movie.dart';

import 'package:movie_catalog/services/movie_service.dart';

import 'package:http/http.dart' as http;

class HomeScreen extends StatelessWidget {
  MovieService _service;
  HomeScreen() {
    _service = new MovieService();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movie Catalog',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO
              // Make a filtered list on the genre, title, year of the movies
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Movie>>(
        future: _service.fetchAllMovies(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? _buildGridTiles(snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
      // body: GridView.count(
      //   primary: true,
      //   padding: EdgeInsets.fromLTRB(2.0, 3.0, 2.0, 3.0),
      //   crossAxisCount: 3,
      //   childAspectRatio: 0.555,
      //   children: _buildGridTiles(),
      // ),
    );
  }

  Widget _buildGridTiles(List<Movie> movies) {
    return GridView.builder(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        return MovieCard(
          id: 1,
        );
      },
    );
    // List<MovieCard> movieCards = new List<MovieCard>();

    // movies.forEach((movie) {
    //   movieCards.add(MovieCard(
    //     id: movie.id,
    //   ));
    // });
    // return movieCards;
  }
}
