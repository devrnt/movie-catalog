import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  final String title;
  final int year;
  final String imageUrl;

  MovieCard({this.title, this.year, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}
