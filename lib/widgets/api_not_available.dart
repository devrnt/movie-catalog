import 'package:flutter/material.dart';
import 'package:movie_catalog/data/strings.dart';

class ApiNotAvailable extends StatelessWidget {
  const ApiNotAvailable({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Icon(Icons.cancel, size: 50.0, color: Theme.of(context).accentColor),
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
          Text('Try again later')
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
