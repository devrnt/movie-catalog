import 'package:flutter/material.dart';

import 'package:movie_catalog/colors.dart';

import 'package:movie_catalog/screens/home_screen.dart';

void main() {
  runApp(new MovieCatalog());
}

class MovieCatalog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Movie Catalog',
      home: new HomeScreen(),
      theme: _buildBlackTheme(),
    );
  }

  ThemeData _buildBlackTheme() {
    final ThemeData base = ThemeData.dark();
    return base.copyWith(
      accentColor: kAccentColor,
      primaryColor: kPrimaryColor,
      primaryColorLight: kPrimaryLight,
      primaryColorDark: kPrimaryDark,
      scaffoldBackgroundColor: kPrimaryColor,
      cardColor: kPrimaryDark,
      textSelectionColor: kAccentColor,

      textTheme: _buildBlackTextTheme(base.textTheme),
      primaryTextTheme: _buildBlackTextTheme(base.primaryTextTheme),
      accentTextTheme: _buildBlackTextTheme(base.accentTextTheme),

      primaryIconTheme: base.iconTheme.copyWith(
        color: kIconColor
      )

      // TODO: Add the icon themes (103)
      // TODO: Decorate the inputs (103)
    );
  }

  TextTheme _buildBlackTextTheme(TextTheme base) {
    return base
        .copyWith(
          headline: base.headline.copyWith(
            fontWeight: FontWeight.normal,
          ),
          title: base.title.copyWith(fontSize: 18.0),
          caption: base.caption.copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 14.0,
          ),
        )
        .apply(
          fontFamily: 'OpenSans',
          displayColor: kPrimaryColor,
          bodyColor: kSecondaryColor,
        );
  }
}
