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
              onPressed: () { },
            ),
          ],
        ),
        body: GridView.count(
            primary: true,
            padding: EdgeInsets.fromLTRB(1.0, 3.0, 1.0, 1.0),
            crossAxisCount: 3,
            mainAxisSpacing: 0.0,
            childAspectRatio: 0.55,
            children: _buildGridTiles()));
  }

  List<Widget> _buildGridTiles() {
    List<MovieCard> movieCards = new List<MovieCard>();
    movies.forEach((movie) {
      movieCards.add(MovieCard(
          title: movie.title, year: movie.year, imageUrl: movie.coverImage));
    });
    return movieCards;
  }
}
