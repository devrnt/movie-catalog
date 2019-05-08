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
                  home: HomeScreen(darkModeEnabled: darkModeEnabled),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
