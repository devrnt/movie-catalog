import 'package:flutter/material.dart';

import 'package:movie_catalog/screens/movie_details_screen.dart';
import 'package:movie_catalog/services/movie_service.dart';

class MovieCard extends StatelessWidget {
  final int id;
  final String title;
  final int year;
  final String imageUrl;

  final MovieService _movieService = new MovieService();

  MovieCard({this.id, this.title, this.year, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetails(
                    movie: _movieService.getMovie(id),
                  ),
            ),
          );
        },
        child: Card(
          elevation: 1.2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Image.network(
                  imageUrl,
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
                          title,
                        ),
                      ),
                      Text(
                        year.toString(),
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      )
                    ]),
              )),
            ],
          ),
        ));
  }
}
