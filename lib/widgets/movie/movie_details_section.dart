import 'package:flutter/material.dart';

class MovieDetailsSection extends StatelessWidget {
  final String title;
  final Widget child;

  MovieDetailsSection({this.title, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color:
                    Theme.of(context).textTheme.subhead.color.withOpacity(0.3),
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
          ),
          child
        ],
      ),
    );
  }
}
