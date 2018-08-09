import 'package:flutter/material.dart';
import 'package:movie_catalog/models/movie.dart';

class MovieDetails extends StatelessWidget {
  final Movie movie;

  MovieDetails({this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
      ),
      body: ListView(
        children: <Widget>[
          Stack(
            alignment: Alignment(-0.9, 5.0),
            children: <Widget>[
              Image.network(movie.backgroundImage),
              Image.network(
                movie.coverImage,
                height: 170.0,
              )
            ],
          ),
          Container(
            width: 120.0,
            height: 80.0,
            padding: EdgeInsets.fromLTRB(0.0, 30.0, 70.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  movie.year.toString(),
                  style: TextStyle(fontSize: 15.0, color: Colors.grey),
                ),
                Text(
                  movie.title,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB( 0.0,  40.0,  0.0,  20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildTextIconWidget(_fromMinutesToHourNotation(movie.runtime),
                    Icons.access_time),
                _buildTextIconWidget(movie.rating.toString(), Icons.star)
              ],
            ),
          ),
          Container(
            child: Text(movie.summary, style: TextStyle(color: Colors.grey[700]),),
            padding: EdgeInsets.symmetric(horizontal: 15.0),
          ),
        ],
      ),
    );
  }

  String _fromMinutesToHourNotation(int minutes) {
    // imagine we get 60 minutes => return '1h'
    // 90mintues => return 1:30h

    int amountOfHours = (minutes / 60).floor();
    int amountOfMinutes = minutes % 60;

    String format =
        ' ' + amountOfHours.toString() + ':' + amountOfMinutes.toString();
    print(format);
    return format;
  }

  Widget _buildTextIconWidget(String text, IconData icon) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.0),
          child: Icon(
            icon,
            size: 14.0,
            color: Colors.grey,
          ),
        ),
        Text((text)),
      ],
    );
  }
}
