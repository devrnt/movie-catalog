import 'package:flutter/material.dart';
import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/bloc/movie_bloc.dart';
import 'package:movie_catalog/data/strings.dart';

class ApiNotAvailable extends StatelessWidget {
  const ApiNotAvailable({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MovieBloc _movieBloc = BlocProvider.of<MovieBloc>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Oops...',
              style: Theme.of(context).textTheme.title.copyWith(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                iconSize: 20.0,
                padding: EdgeInsets.all(1.0),
                icon: Icon(Icons.help),
                onPressed: () {
                  _showHelpDialog(context);
                },
              ),
              Text(Strings.serverUnavailable),
            ],
          ),
          RaisedButton(
            color: Theme.of(context).accentColor,
            onPressed: () {
              Scaffold.of(context).showSnackBar(
                new SnackBar(
                  content: new Text(
                    Strings.retry,
                    style: TextStyle(color: Colors.black.withOpacity(0.8)),
                  ),
                  backgroundColor: Theme.of(context).accentColor,
                ),
              );
              _movieBloc.resetMovieBlocIn.add(null);
            },
            child: Text(
              Strings.retryButton,
              style: TextStyle(
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).primaryColorLight,
            title: Text('YIFY server'),
            content: Text(
                'The YIFY server is offline, there is nothing we can do at the moment'),
          );
        });
  }
}
