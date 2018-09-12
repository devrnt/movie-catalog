import 'package:flutter/material.dart';
import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/widgets/movie_card.dart';

class MovieGridSaved extends StatelessWidget {
  final List<Movie> movies;
  MovieGridSaved({this.movies});

  @override
  Widget build(BuildContext context) {
    return movies.length > 0
        ? GridView.builder(
            padding: EdgeInsets.fromLTRB(2.0, 5.0, 2.0, 3.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.545,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return MovieCard(
                movie: movies[index],
              );
            },
          )
        : Center(
            child: Text('Your library is empty'),
          );
  }
}
