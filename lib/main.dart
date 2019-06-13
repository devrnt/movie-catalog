import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_catalog/services/sentry_service.dart';
import 'package:sentry/sentry.dart';
import 'package:debug_mode/debug_mode.dart';

import 'package:movie_catalog/config/keys.dart';
import 'package:movie_catalog/config/flavor_config.dart';

import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/bloc/liked_bloc.dart';
import 'package:movie_catalog/bloc/movie_bloc.dart';
import 'package:movie_catalog/bloc/search_bloc.dart';
import 'package:movie_catalog/bloc/suggestions_bloc.dart';
import 'package:movie_catalog/bloc/theme_bloc.dart';

import 'package:movie_catalog/screens/home_screen.dart';
import 'package:movie_catalog/theme/theme_builder.dart';

final SentryClient _sentryClient = new SentryClient(dsn: Keys.sentryDsn);

Future<Null> main() async {
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (DebugMode.isInDebugMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to Sentry
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  runZoned<Future<Null>>(() async {
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
  }, onError: (error, stackTrace) async {
    await SentryService.reportError(_sentryClient, error, stackTrace);
  });
}

class MovieCatalog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeBloc _themeBloc = BlocProvider.of<ThemeBloc>(context);

    String appNameSuffix =
        FlavorConfig.of(context).flavorBuild == FlavorBuild.Pro ? 'Pro' : '';

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
              initialData: true,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                bool darkModeEnabled = snapshot.data;
                return MaterialApp(
                  title: 'Movie Catalog $appNameSuffix',
                  theme: darkModeEnabled
                      ? ThemeBuilder.buildBlackTheme()
                      : ThemeBuilder.buildLightTheme(),
                  darkTheme: ThemeBuilder.buildBlackTheme(),
                  home: HomeScreen(
                    darkModeEnabled: darkModeEnabled,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
