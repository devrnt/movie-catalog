import 'package:flutter/material.dart';
import 'package:movie_catalog/data/dummy_data.dart';

import 'package:movie_catalog/widgets/movie_card.dart';

class HomeScreen extends StatelessWidget {
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
      body: GridView.count(
        primary: true,
        padding: EdgeInsets.fromLTRB(2.0, 3.0, 2.0, 3.0),
        crossAxisCount: 3,
        childAspectRatio: 0.555,
        children: _buildGridTiles(),
      ),
    );
  }

  List<Widget> _buildGridTiles() {
    List<MovieCard> movieCards = new List<MovieCard>();
    movies.forEach((movie) {
      movieCards.add(MovieCard(
          id: movie.id,
        ));
    });
    return movieCards;
  }
}
