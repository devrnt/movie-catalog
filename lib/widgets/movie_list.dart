import 'package:flutter/material.dart';

import 'package:movie_catalog/data/strings.dart';

import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/widgets/movie_card.dart';

class MovieList extends StatefulWidget {
  final List<Movie> movies;

  MovieList({this.movies});

  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList>
    with AutomaticKeepAliveClientMixin<MovieList> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.movies.isNotEmpty
        ? ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 12, 2, 0),
            itemCount: widget.movies.length,
            itemBuilder: (BuildContext context, int index) =>
                MovieCard(movie: widget.movies[index]))
        : Center(child: Text(Strings.emptyLibrary));
  }
}
