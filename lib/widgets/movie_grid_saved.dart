import 'package:flutter/material.dart';
import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/widgets/movie_card_grid.dart';

class MovieGridSaved extends StatelessWidget {
  final List<Movie> movies;
  MovieGridSaved({this.movies});

  @override
  Widget build(BuildContext context) {
    return movies.length > 0
        ? GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.58,
            ),
            padding: EdgeInsets.fromLTRB(2.0, 5.0, 2.0, 3.0),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return MovieCardGrid(
                movie: movies[index],
              );
            },
          )
        : Center(
            child: Text('Your library is empty'),
          );
  }
}
