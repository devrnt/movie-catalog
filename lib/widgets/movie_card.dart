import 'package:flutter/material.dart';

import 'package:movie_catalog/screens/movie_details_screen.dart';

import 'package:movie_catalog/models/movie.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;

  MovieCard({this.movie});

  @override
  MovieCardState createState() {
    return new MovieCardState();
  }
}

class MovieCardState extends State<MovieCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetails(
                    movie: widget.movie,
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
            child: Image.network(
              widget.movie.coverImage,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 7.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      widget.movie.title.replaceAll(' ', '').trim().length < 14
                          ? widget.movie.title
                          : widget.movie.title.substring(0,13) + '...',
                    ),
                  ),
                  Text(
                    widget.movie.year.toString(),
                    style: TextStyle(
                        color: Theme.of(context).primaryIconTheme.color,
                        fontSize: 13.0),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
