import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/bloc/liked_bloc.dart';
import 'package:movie_catalog/bloc/movie_bloc.dart';
import 'package:movie_catalog/bloc/search_bloc.dart';
import 'package:movie_catalog/bloc/suggestions_bloc.dart';
import 'package:movie_catalog/bloc/theme_bloc.dart';

import 'package:movie_catalog/config/flavor_config.dart';
import 'package:movie_catalog/screens/home_screen.dart';
import 'package:movie_catalog/theme/theme_builder.dart';

import 'package:sentry/sentry.dart';

final SentryClient _sentry = new SentryClient(
    dsn: 'https://44ee1a5fe98040a2b2258a32f4cf31f4@sentry.io/1295373');

void main() {
  final flavorConfig = FlavorConfig(
    child: MovieCatalog(),
    flavorBuild: FlavorBuild.Free,
  );

  runApp(
    BlocProvider<ThemeBloc>(
      bloc: ThemeBloc(),
      child: flavorConfig,
    ),
  );
}

class MovieCatalog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeBloc _themeBloc = BlocProvider.of<ThemeBloc>(context);

    String appNameSuffix = '';
    if (FlavorConfig.of(context).flavorBuild == FlavorBuild.Pro) {
      appNameSuffix = 'Pro';
    }

    return BlocProvider<MovieBloc>(
      bloc: MovieBloc(),
      child: BlocProvider<LikedBloc>(
        bloc: LikedBloc(),
        child: BlocProvider<SuggestionsBloc>(
          bloc: SuggestionsBloc(),
          child: BlocProvider<SearchBloc>(
              bloc: SearchBloc(),
              child: StreamBuilder(
                stream: _themeBloc.darkThemeEnabled,
                initialData: false,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  bool darkModeEnabled = snapshot.data;
                  return MaterialApp(
                    title: 'Movie Catalog $appNameSuffix'.trim(),
                    theme: darkModeEnabled
                        ? ThemeBuilder.buildBlackTheme()
                        : ThemeBuilder.buildLightTheme(),
                    home: HomeScreen(darkModeEnabled: darkModeEnabled),
                  );
                },
              )),
        ),
      ),
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
