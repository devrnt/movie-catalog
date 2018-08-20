import 'package:flutter/material.dart';

import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/services/movie_service.dart';
import 'package:movie_catalog/widgets/movie_card.dart';

import 'package:http/http.dart' as http;

class MovieGrid extends StatefulWidget {
  List<Movie> movies;

  MovieGrid({this.movies});

  @override
  _MovieGridState createState() => _MovieGridState();
}

class _MovieGridState extends State<MovieGrid> {
  List<Movie> movies;
  int currentPage = 2;

  MovieService _movieService;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    movies = widget.movies;
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
        childAspectRatio: 0.555,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        print('Length that is inserted from the builder' + movies.length.toString());
        return MovieCard(
          movie: movies[index],
        );
      },
    );
  }

  void _scrollListener() {
    print(_scrollController.position.pixels);
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      print('Scrolled to the end!');
      _movieService
          .fetchLatestMovies(http.Client(), currentPage)
          .then((newMovies) {
        setState(() {
          movies.addAll(newMovies);
        });
        newMovies.forEach((m) {
          print(m.title);
        });
        print('length: ' + movies.length.toString());
      });
      currentPage++;
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
