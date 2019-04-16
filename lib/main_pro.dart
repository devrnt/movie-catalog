import 'package:flutter/material.dart';
import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/bloc/theme_bloc.dart';
import 'package:movie_catalog/config/flavor_config.dart';

import 'main.dart';

void main() {
  final flavorConfig = FlavorConfig(
    child: MovieCatalog(),
    flavorBuild: FlavorBuild.Pro,
  );

  runApp(
    BlocProvider<ThemeBloc>(
      bloc: ThemeBloc(),
      child: flavorConfig,
    ),
  );
}
