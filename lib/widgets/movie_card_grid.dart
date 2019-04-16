import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/bloc/liked_bloc.dart';
import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/screens/movie_details_screen.dart';
import 'package:movie_catalog/services/movie_service.dart';

import 'package:http/http.dart' as http;

class MovieCardGrid extends StatelessWidget {
  final Movie movie;
  final MovieService _movieService = new MovieService();

  MovieCardGrid({this.movie}) {
    // Movie comes from storage
    if (movie.torrents.length == 0) {
      addMovieDetails(movie.id)
          .then((Movie updatedMovie) => movie.torrents = updatedMovie.torrents);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              maintainState: true,
              builder: (context) => MovieDetails(
                    movie: movie,
                    likedMoviesStream:
                        BlocProvider.of<LikedBloc>(context).likedMoviesOut,
                  ),
            ),
          ),
      child: _buildCard(context: context),
    );
  }

  Widget _buildCard({BuildContext context}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2.0, 1.0, 2.0, 1.0),
      child: Card(
        elevation: 4.0,
        color: Theme.of(context).primaryColorLight,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: FadeInImage.assetNetwork(
                  fadeInDuration: Duration(milliseconds: 550),
                  image: movie.coverImageMedium ??
                      movie.coverImageLarge ??
                      'assets/images/cover_placeholder.jpg',
                  placeholder: 'assets/images/cover_placeholder.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(6.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.0),
                    ),
                    Text(
                      movie.year.toString(),
                      style: TextStyle(
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              .withOpacity(0.6),
                          fontSize: 13.0),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Movie> addMovieDetails(int id) async {
    Movie movie = await _movieService.fetchMovieById(http.Client(), id);
    return movie;
  }
}
