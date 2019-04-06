import 'package:flutter/material.dart';
import 'package:movie_catalog/models/movie.dart';

import 'package:movie_catalog/widgets/movie_card_design.dart';
import 'package:movie_catalog/widgets/movie_card_grid.dart';

class SortableMovieGrid extends StatefulWidget {
  final List<Movie> movies;
  final dynamic config;

  SortableMovieGrid({this.movies, this.config});

  @override
  _SortableMovieGridState createState() => _SortableMovieGridState();
}

class _SortableMovieGridState extends State<SortableMovieGrid> {
  int currentPage = 2;

  @override
  Widget build(BuildContext context) {
    return widget.movies.length > 0
        ? GridView.builder(
            padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.58,
            ),
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              return MovieCardGrid(
                movie: widget.movies[index],
              );
            },
          )
        : Center(child: Text('No search results'));
  }

  Widget _buildHeader() {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        FlatButton(
          child: Row(
            children: <Widget>[Text('RATING'), Icon(Icons.arrow_drop_down)],
          ),
          onPressed: () {
            setState(() {
              widget.movies.sort((a, b) => a.rating.compareTo(b.rating));
            });
          },
        ),
        FlatButton(
          child: Row(
            children: <Widget>[Text('LATEST'), Icon(Icons.arrow_drop_down)],
          ),
          onPressed: () {},
        )
      ],
    );
  }

  Widget _buildBody(List<Movie> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // _buildHeader(),
        Expanded(child: _buildGrid(data)),
      ],
    );
  }

  Widget _buildGrid(List<Movie> data) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(2.0, 5.0, 2.0, 3.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.545,
      ),
      itemCount: widget.movies.length,
      itemBuilder: (context, index) {
        return MovieCardDesign(
          movie: widget.movies[index],
        );
      },
    );
  }
}
