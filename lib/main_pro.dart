import 'dart:async';

import 'package:debug_mode/debug_mode.dart';
import 'package:flutter/material.dart';
import 'package:movie_catalog/blocs/theme_bloc.dart';
import 'package:movie_catalog/config/flavor_config.dart';
import 'package:movie_catalog/config/keys.dart';
import 'package:movie_catalog/services/sentry_service.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';

import 'main.dart';

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
      flavorBuild: FlavorBuild.Pro,
      child: Provider<ThemeBloc>(
        create: (_) => ThemeBloc(),
        child: MovieCatalog(),
      ),
    );

    runApp(movieCatalogApp);
  }, onError: (error, stackTrace) async {
    await SentryService.reportError(_sentryClient, error, stackTrace);
  });
}
