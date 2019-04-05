import 'package:flutter/material.dart';

import 'package:movie_catalog/models/movie.dart';

import 'package:movie_catalog/widgets/movie_card_design.dart';

class MovieList extends StatefulWidget {
  final List<Movie> movies;
  final String type;
  // config used for passing the filter config
  final dynamic config;

  MovieList(this.movies, this.type, [this.config]);

  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList>
    with AutomaticKeepAliveClientMixin<MovieList> {
  int currentPageLatest = 2;
  int currentPagePopular = 2;
  int currentPageConfig = 2;

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return widget.movies.length > 0
        ? ListView.builder(
            padding: EdgeInsets.fromLTRB(0.0, 12.0, 2.0, 0.0),
            itemCount: widget.movies.length,
            itemBuilder: (BuildContext context, int index) {
              return new Column(
                children: <Widget>[
                  MovieCardDesign(
                    movie: widget.movies[index],
                  ),
                ],
              );
            },
          )
        : Center(
            child: widget.type != 'liked'
                ? Text('Your library is empty')
                : Text('Your shelf is empty'));
  }
}
