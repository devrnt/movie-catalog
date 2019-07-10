import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_catalog/services/sentry_service.dart';
import 'package:sentry/sentry.dart';
import 'package:debug_mode/debug_mode.dart';
import 'package:provider/provider.dart';

import 'package:movie_catalog/config/keys.dart';
import 'package:movie_catalog/config/flavor_config.dart';

import 'package:movie_catalog/blocs/liked_bloc.dart';
import 'package:movie_catalog/blocs/movie_bloc.dart';
import 'package:movie_catalog/blocs/theme_bloc.dart';

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
    final movieCatalogApp = FlavorConfig(
      flavorBuild: FlavorBuild.Free,
      child: Provider<ThemeBloc>(
        builder: (_) => ThemeBloc(),
        child: MovieCatalog(),
      ),
    );

    runApp(movieCatalogApp);
  }, onError: (error, stackTrace) async {
    await SentryService.reportError(_sentryClient, error, stackTrace);
  });
}

class MovieCatalog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _themeBloc = Provider.of<ThemeBloc>(context);

    final appNameSuffix =
        FlavorConfig.of(context).flavorBuild == FlavorBuild.Pro ? 'Pro' : '';

    return MultiProvider(
      providers: [
        Provider(builder: (_) => MovieBloc()),
        Provider(builder: (_) => LikedBloc()),
      ],
      child: StreamBuilder<bool>(
        stream: _themeBloc.darkThemeEnabled,
        initialData: true,
        builder: (context, snapshot) {
          final darkModeEnabled = snapshot.data;
          return MaterialApp(
            title: 'Movie Catalog $appNameSuffix',
            theme: darkModeEnabled
                ? ThemeBuilder.buildBlackTheme()
                : ThemeBuilder.buildLightTheme(),
            darkTheme: ThemeBuilder.buildBlackTheme(),
            home: HomeScreen(darkModeEnabled: darkModeEnabled),
          );
        },
      ),
    );
  }
}
