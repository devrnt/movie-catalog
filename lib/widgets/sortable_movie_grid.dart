import 'package:flutter/material.dart';
import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/services/movie_service.dart';

import 'package:http/http.dart' as http;
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
  MovieService _movieService;
  ScrollController _scrollController;

  int currentPage = 2;

  @override
  void initState() {
    super.initState();
    _movieService = new MovieService();
    _scrollController = new ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void deactivate() {
    _scrollController.removeListener(() => _scrollController);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return widget.movies.length > 0
        ? GridView.builder(
            padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
            controller: _scrollController,
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
    // ? FutureBuilder<List<Movie>>(
    //     future: _movieService.fetchMoviesByConfig(
    //         http.Client(),
    //         1,
    //         widget.config['genre'],
    //         widget.config['quality'],
    //         widget.config['rating']),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasError) print(snapshot.error);
    //       if (snapshot.hasData) {
    //         return _buildBody(
    //           snapshot.data,
    //         );
    //       } else
    //         return Center(child: CircularProgressIndicator());
    //     },
    //   )
    // : Center(child: Text('No search results'));
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _movieService
          .fetchMoviesByConfig(
              http.Client(),
              currentPage,
              widget.config['genre'],
              widget.config['quality'],
              widget.config['rating'])
          .then((newMovies) {
        setState(() {
          widget.movies.addAll(newMovies);
        });
        currentPage++;
      });
    }
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
      controller: _scrollController,
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
