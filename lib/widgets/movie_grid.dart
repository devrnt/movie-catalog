import 'package:flutter/material.dart';

import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/services/movie_service.dart';
import 'package:movie_catalog/widgets/movie_card.dart';

import 'package:http/http.dart' as http;

class MovieGrid extends StatefulWidget {
  final List<Movie> movies;
  final String type;

  MovieGrid({this.movies, this.type});

  @override
  _MovieGridState createState() => _MovieGridState();
}

class _MovieGridState extends State<MovieGrid>
    with AutomaticKeepAliveClientMixin<MovieGrid> {
  List<Movie> movies;
  int currentPageLatest = 2;
  int currentPagePopular = 2;

  MovieService _movieService;
  ScrollController _scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    movies = widget.movies.where((movie) => movie.rating > 0).toList();
    _movieService = new MovieService();

    _scrollController = new ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void deactivate() {
    _scrollController.removeListener(() => _scrollController);
    print('event removed!!!!!!!!!!!!!!!!');
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(2.0, 5.0, 2.0, 3.0),
      controller: _scrollController,
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
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (widget.type == 'latest') {
        _movieService
            .fetchLatestMovies(http.Client(), currentPageLatest)
            .then((newMovies) {
          setState(() {
            movies.addAll(newMovies);
          });
          currentPageLatest++;
        });
      }
      if (widget.type == 'popular') {
        _movieService
            .fetchPopularMovies(http.Client(), currentPagePopular)
            .then((newMovies) {
          setState(() {
            movies.addAll(newMovies);
          });
          currentPagePopular++;
        });
      }
    }
  }
  // if (_scrollController.position.atEdge) {
  //   _movieService.fetchLatestMovies(http.Client(), 50).then((newMovies) {
  //     print(newMovies);
  //     setState(() {
  //       movies.addAll(newMovies);
  //     });
  //   });
  // }

}
