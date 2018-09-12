import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:movie_catalog/models/movie.dart';

import 'package:movie_catalog/screens/search_screen.dart';

import 'package:movie_catalog/services/movie_service.dart';
import 'package:movie_catalog/services/storage_service.dart';

import 'package:movie_catalog/widgets/movie_grid.dart';
import 'package:movie_catalog/widgets/movie_grid_saved.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  MovieService _movieService;
  StorageService _storageService;
  StreamController _streamController;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final List<Tab> _tabs = [
    Tab(child: Text('latest'.toUpperCase())),
    Tab(child: Text('top rated'.toUpperCase())),
    Tab(child: Text('library'.toUpperCase())),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: _tabs.length);

    _movieService = new MovieService();
    _storageService = new StorageService();
    _streamController = new StreamController();

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() => _connectionStatus = result.toString());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(),
        body: online() ? _buildTabBarView() : noInternetConnection());
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
            'Please turn on your internet connection.\nMake sure you have a working network connection.\nVPN are not supported at the moment.\nTry turning your WiFi on and off.',
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

  AppBar _buildAppBar() {
    return AppBar(
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
                : print('Not online, searching is unavailable');
          },
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Theme.of(context).accentColor,
        tabs: _tabs,
      ),
    );
  }

  TabBarView _buildTabBarView() {
    _fetchLatestMovies();
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        // StreamBuilder(
        //   stream: _streamController.stream.asBroadcastStream(),
        //   builder: (context, snapshot) {
        //     if (snapshot.hasError)
        //       return Center(child:Text('There was an error. Please try again later.'));
        //     switch (snapshot.connectionState) {
        //       case ConnectionState.waiting:
        //         return Center(child: CircularProgressIndicator());
        //         break;
        //       case ConnectionState.active:
        //         return MovieGrid(snapshot.data, 'latest');
        //         break;
        //       default:
        //         print(
        //             'ConnectionState of the snapshot is ${snapshot.connectionState}');
        //             return Text('Implemnt this further');
        //     }
        //   },
        // ),
        FutureBuilder<List<Movie>>(
          future: _fetchLatestMovies(),
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
          future: _fetchPopularMovies(),
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
          future: _fetchSavedMovies(),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);
            return snapshot.hasData
                ? MovieGridSaved(
                    movies: snapshot.data,
                  )
                : Center(child: CircularProgressIndicator());
          },
        )
      ],
    );
  }

  Future<List<Movie>> _fetchLatestMovies() {
    return _movieService.fetchLatestMovies(http.Client(), 1);
  }

  Future<List<Movie>> _fetchPopularMovies() {
    return _movieService.fetchPopularMovies(http.Client(), 1);
  }

  Future<List<Movie>> _fetchSavedMovies() {
    return _storageService.readFile();
  }
}
