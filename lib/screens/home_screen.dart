import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/services.dart';

import 'package:movie_catalog/services/movie_service.dart';

import 'package:movie_catalog/widgets/movie_card.dart';

import 'package:movie_catalog/models/movie.dart';

import 'package:movie_catalog/widgets/movie_grid.dart';

import 'package:connectivity/connectivity.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController _scrollController;
  MovieService _movieService;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    _scrollController = new ScrollController();
    _movieService = new MovieService();
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() => _connectionStatus = result.toString());
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<Null> initConnectivity() async {
    String connectionStatus;
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } on PlatformException catch (e) {
      print('There occured an error: ' + e.toString());
      connectionStatus = 'Failed to get connectivity';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    setState(() {
      _connectionStatus = connectionStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movie Catalog',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO
              // Make a filtered list on the genre, title, year of the movies
            },
          ),
        ],
      ),
      body: !online()
          ? showAlert()
          : FutureBuilder<List<Movie>>(
              future: _movieService.fetchLatestMovies(http.Client(), 1),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                return snapshot.hasData
                    ? MovieGrid(movies: snapshot.data)
                    : Center(child: CircularProgressIndicator());
              },
            ),
      // body: GridView.count(
      //   primary: true,
      //   padding: EdgeInsets.fromLTRB(2.0, 3.0, 2.0, 3.0),
      //   crossAxisCount: 3,
      //   childAspectRatio: 0.555,
      //   children: _buildGridTiles(),
      // ),
    );
  }

  Widget showAlert() {
    print('Alert was shown');
    _neverSatisfied();
    return null;
  }

  bool online() {
    return _connectionStatus == 'ConnectivityResult.none' ? false : true;
  }

  Future<Null> _neverSatisfied() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No internet connection'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please turn on your internet.'),
                Text(
                  'This app will be closed.',
                  style: TextStyle(color: Colors.grey, fontSize: 14.0),
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('EXIT'),
              onPressed: () => SystemNavigator.pop(),
            ),
          ],
        );
      },
    );
  }
}
