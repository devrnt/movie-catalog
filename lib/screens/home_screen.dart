import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:movie_catalog/models/movie.dart';

import 'package:movie_catalog/screens/search_screen.dart';

import 'package:movie_catalog/services/movie_service.dart';

import 'package:movie_catalog/widgets/movie_grid.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MovieService _movieService;
  // StorageService _storageService;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final List<Tab> _tabs = [
    Tab(
      child: Text('LATEST'),
    ),
    Tab(
      child: Text('TOP RATED'),
    ),
    // Tab(
    //   child: Text('LIKED'),
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Movie Catalog',
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: _tabs,
            indicatorColor: Theme.of(context).accentColor,
          ),
        ),
        body: !online()
            ? noInternetConnection()
            : TabBarView(
                children: <Widget>[
                  FutureBuilder<List<Movie>>(
                    future: _movieService.fetchLatestMovies(http.Client(), 1),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Text('ffefefe');
                      return snapshot.hasData
                          ? MovieGrid(
                              snapshot.data,
                              'latest',
                            )
                          : Center(child: CircularProgressIndicator());
                    },
                  ),
                  FutureBuilder<List<Movie>>(
                    future: _movieService.fetchPopularMovies(http.Client(), 1),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) print(snapshot.error);
                      return snapshot.hasData
                          ? MovieGrid(
                              snapshot.data,
                              'popular',
                            )
                          : Center(child: CircularProgressIndicator());
                    },
                  ),
                  // Row(children: <Widget>[
                  //   FloatingActionButton(
                  //     onPressed: () {},
                  //     child: Text('Klik'),
                  //   ),
                  //   FloatingActionButton(
                  //     onPressed: () {},
                  //     child: Text('Write'),
                  //   )
                  // ])
                ],
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _movieService = new MovieService();
    // _storageService = new StorageService();
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

  Widget noInternetConnection() {
    _showAlert();
    return Padding(child:Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Text('No internet connection'),
        Text(
          'Please turn on your internet connection.\nMake sure you have a working network connection.\nVPN are not supported at the moment.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    ), padding: EdgeInsets.symmetric(horizontal: 20.0),);
  }

  bool online() {
    print('Hier is de connectie: $_connectionStatus');
    return _connectionStatus == 'ConnectivityResult.none' ? false : true;
  }

  Future<Null> _showAlert() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Please turn on your internet.'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please turn on your internet.'),
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
