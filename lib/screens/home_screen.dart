import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_catalog/services/movie_service.dart';

import 'package:movie_catalog/widgets/movie_card.dart';

import 'package:movie_catalog/models/movie.dart';

import 'package:http/http.dart' as http;
import 'package:movie_catalog/widgets/movie_grid.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController _scrollController;
  MovieService _movieService;

  @override
  void initState() {
    _scrollController = new ScrollController();
    _movieService = new MovieService();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
        future: _movieService.fetchLatestMovies(http.Client(), 1),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? MovieGrid(movies: snapshot.data)
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
    print(movies.length);
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(2.0, 3.0, 2.0, 3.0),
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.555,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        return MovieCard(
          movie: movies[index],
        );
      },
    );

    // Use dummt data
    // List<MovieCard> movieCards = new List<MovieCard>();

    // movies.forEach((movie) {
    //   movieCards.add(MovieCard(
    //     id: movie.id,
    //   ));
    // });
    // return movieCards;
  }
}
