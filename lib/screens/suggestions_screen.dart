import 'package:flutter/material.dart';

import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/bloc/suggestions_bloc.dart';

import 'package:movie_catalog/widgets/movie_list.dart';
import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/widgets/api_not_available.dart';

class SuggestionsScreen extends StatefulWidget {
  @override
  _SuggestionsScreenState createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  @override
  Widget build(BuildContext context) {
    final SuggestionsBloc bloc = BlocProvider.of<SuggestionsBloc>(context)
      ..getSuggestions();

    return Scaffold(
      appBar: AppBar(
        title: Text('Suggestions'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      content: Text(
                          'Suggestions are based on the movies in your library.'),
                    );
                  });
            },
          )
        ],
      ),
      body: StreamBuilder<List<Movie>>(
        stream: bloc.suggestionsOut,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              if (snapshot.hasError) {
                // Worst solution ever
                if (snapshot.error.toString() == 'Bad state: No element') {
                  return Center(
                      child: Text(
                          'No suggestions available.\nClick the help icon for more info.'));
                }
                return ApiNotAvailable();
              } else
                return MovieList(movies: snapshot.data);
          }
        },
      ),
    );
  }
}
