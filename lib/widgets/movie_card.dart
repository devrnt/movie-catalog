import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_catalog/colors.dart';

import 'package:movie_catalog/screens/movie_details_screen.dart';

import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/services/movie_service.dart';

import 'package:http/http.dart' as http;

class MovieCard extends StatelessWidget {
  Movie movie;
  MovieService _movieService;

  MovieCard({this.movie}) {
    _movieService = new MovieService();
    // if the movies are stored on the users phone
    // we check on torrents legth equals 0 because torrents are not stored on the phone
    if (movie.torrents.length == 0) {
      addMovieDetails(movie.id)
          .then((Movie updated) => movie.torrents = updated.torrents);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              maintainState: true,
              builder: (context) => MovieDetails(
                    movie: movie,
                  ),
            ),
          );
        },
        child: _buildCard());
  }

  Card _buildCard() {
    return Card(
      elevation: 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: FadeInImage.assetNetwork(
              fadeInDuration: Duration(milliseconds: 750),
              image: movie.coverImageMedium,
              placeholder: 'assets/images/cover_placeholder.jpg',
              fit: BoxFit.fill,
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(7.0, 3.0, 0.0, 3.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 1.0),
                    child: Text(
                      movie.year.toString(),
                      style: TextStyle(color: kIconColor, fontSize: 13.0),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Movie> addMovieDetails(int id) async {
    Movie movie = await _movieService.fetchMovieById(http.Client(), id);
    return movie;
  }
} 
