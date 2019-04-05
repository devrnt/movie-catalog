import 'package:flutter/material.dart';

import 'package:movie_catalog/models/movie.dart';

import 'package:movie_catalog/widgets/movie_card_grid.dart';

class MovieGrid extends StatefulWidget {
  final List<Movie> movies;
  final String type;
  // config used for passing the filter config
  final dynamic config;

  MovieGrid(this.movies, this.type, [this.config]);

  @override
  _MovieGridState createState() => _MovieGridState();
}

class _MovieGridState extends State<MovieGrid>
    with AutomaticKeepAliveClientMixin<MovieGrid> {
  List<Movie> movies;

  int currentPageConfig = 2;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    movies = widget.movies;
  }

  @override
  Widget build(BuildContext context) {
    return movies.length > 0
        ? GridView.builder(
            padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.58,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  MovieCardGrid(
                    movie: movies[index],
                  ),
                ],
              );
            },
          )
        : Center(
            child: widget.type != 'liked'
                ? Text('No search results')
                : Text('Your shelf is empty'));
  }
}
