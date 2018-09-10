import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/models/torrent.dart';

import 'package:movie_catalog/screens/search_screen.dart';

import 'package:movie_catalog/services/movie_service.dart';
import 'package:movie_catalog/services/storage_service.dart';

import 'package:movie_catalog/widgets/movie_grid.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Movie movie = new Movie(
      8521,
      'Pina',
      'Pina long',
      2011,
      'In modern dance since the 1970s, few choreographers have had more influence in the medium than the late Pina Bausch. This film explores the life and work of this artist of movement while we see her company perform her most notable creations where basic things like water, dirt and even gravity take on otherworldly qualities in their dancing.',
      ['Documentary', 'Horror'],
      7.7,
      'https://yts.am/movie/pina-2011',
      'tt1440266',
      92,
      'https://yts.am/assets/images/movies/pina_2011/background.jpg',
      'https://yts.am/assets/images/movies/pina_2011/small-cover.jpg',
      'https://yts.am/assets/images/movies/pina_2011/medium-cover.jpg',
      'https://yts.am/assets/images/movies/pina_2011/large-cover.jpg',
      [
        new Torrent(
            'https://yts.am/assets/images/movies/pina_2011/large-cover.jpg',
            '90CBAC6473DD54F9911E4ADBE0C0CE7C0A2DE6FC',
            '720p',
            931649290,
            new DateTime.now(),
            74,
            57),
        new Torrent(
            'https://yts.am/assets/images/movies/pina_2011/large-cover.jpg',
            '90CBAC6473DD54F9911E4ADBE0C0CE7C0A2DE6FC',
            '720p',
            931649290,
            new DateTime.now(),
            74,
            57),
      ]);
  MovieService _movieService;
  StorageService _storageService;

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
    Tab(
      child: Text('SHELF'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          elevation: 5.0,
          title: Text(
            'Movie Catalog',
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                online()
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(),
                        ),
                      )
                    : null;
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
                      if (snapshot.hasError)
                        return Text('There was an error: ${snapshot.error}');
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
                  FutureBuilder<List<Movie>>(
                    future: _storageService.readFile(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) print(snapshot.error);
                      return snapshot.hasData
                          ? MovieGrid(
                              snapshot.data,
                              'liked',
                            )
                          : Center(child: CircularProgressIndicator());
                    },
                  )
                ],
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _movieService = new MovieService();
    _storageService = new StorageService();
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
    return Padding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            'No internet connection',
            style: TextStyle(fontSize: 16.0),
          ),
          Text(
            'Please turn on your internet connection.\nMake sure you have a working network connection.\nVPN are not supported at the moment.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.0),
    );
  }

  bool online() {
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
