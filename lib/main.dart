import 'dart:async';

import 'package:flutter/material.dart';

import 'package:movie_catalog/colors.dart';

import 'package:movie_catalog/screens/home_screen.dart';

import 'package:sentry/sentry.dart';

import 'package:movie_catalog/sentry_dsn_key.dart';

final SentryClient _sentry = new SentryClient(dsn: dsn);

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
      primaryIconTheme: base.iconTheme.copyWith(color: kIconColor),
      canvasColor: kPrimaryLight,
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
          displayColor: kPrimaryColor,
          bodyColor: kSecondaryColor,
        );
  }

  // Sentry help methods
  bool get isInDebugMode {
    // Assume we're in production mode
    bool inDebugMode = false;

    // Assert expressions are only evaluated during development. They are ignored
    // in production. Therefore, this code will only turn `inDebugMode` to true
    // in our development environments!
    assert(inDebugMode = true);

    return inDebugMode;
  }

  Future<Null> _reportError(dynamic error, dynamic stackTrace) async {
    // Print the exception to the console
    print('Caught error: $error');
    if (isInDebugMode) {
      // Print the full stacktrace in debug mode
      print(stackTrace);
      return;
    } else {
      // Send the Exception and Stacktrace to Sentry in Production mode
      _sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Null> main() async {
    // This captures errors reported by the Flutter framework.
    FlutterError.onError = (FlutterErrorDetails details) async {
      if (isInDebugMode) {
        // In development mode simply print to console.
        FlutterError.dumpErrorToConsole(details);
      } else {
        // In production mode report to the application zone to report to
        // Sentry.
        Zone.current.handleUncaughtError(details.exception, details.stack);
      }
    };

    // This creates a [Zone] that contains the Flutter application and stablishes
    // an error handler that captures errors and reports them.
    //
    // Using a zone makes sure that as many errors as possible are captured,
    // including those thrown from [Timer]s, microtasks, I/O, and those forwarded
    // from the `FlutterError` handler.
    //
    // More about zones:
    //
    // - https://api.dartlang.org/stable/1.24.2/dart-async/Zone-class.html
    // - https://www.dartlang.org/articles/libraries/zones
    runZoned<Future<Null>>(() async {
      runApp(new MovieCatalog());
    }, onError: (error, stackTrace) async {
      await _reportError(error, stackTrace);
    });
  }
}
