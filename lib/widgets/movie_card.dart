import 'package:flutter/material.dart';

import 'package:movie_catalog/screens/movie_details_screen.dart';
import 'package:movie_catalog/services/movie_service.dart';

class MovieCard extends StatefulWidget {
  final int id;
  String title;
  int year;
  String imageUrl;

  final MovieService _movieService = new MovieService();

  MovieCard({this.id}) {
    this.title = _movieService.getMovie(id).title;
    this.year = _movieService.getMovie(id).year;
    this.imageUrl = _movieService.getMovie(id).coverImage;
  }

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
                    movie: widget._movieService.getMovie(widget.id),
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
              widget.imageUrl,
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
                      widget.title,
                    ),
                  ),
                  Text(
                    widget.year.toString(),
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
