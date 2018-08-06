import 'package:flutter/material.dart';

import 'package:movie_catalog/screens/home_screen.dart';

void main() => runApp(new MovieCatalog());

class MovieCatalog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Movie Catalog',
      theme: new ThemeData(
        primarySwatch: Colors.black,
      ),
      home: new HomeScreen(),
    );
  }
}
