import 'package:flutter/material.dart';

import 'package:movie_catalog/data/strings.dart';

import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/widgets/movie_card_grid.dart';

class MovieGrid extends StatefulWidget {
  final List<Movie> movies;

  MovieGrid({this.movies});

  @override
  _MovieGridState createState() => _MovieGridState();
}

class _MovieGridState extends State<MovieGrid>
    with AutomaticKeepAliveClientMixin<MovieGrid> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return widget.movies.isNotEmpty
        ? GridView.builder(
            padding: EdgeInsets.fromLTRB(6.0, 12.0, 0.0, 6.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.56,
            ),
            itemCount: widget.movies.length,
            itemBuilder: (context, index) =>
                MovieCardGrid(movie: widget.movies[index]))
        : Center(child: Text(Strings.emptyLibrary));
  }
}
