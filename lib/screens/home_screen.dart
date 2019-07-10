import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_catalog/blocs/liked_bloc.dart';
import 'package:movie_catalog/blocs/movie_bloc.dart';
import 'package:movie_catalog/blocs/search_bloc.dart';
import 'package:movie_catalog/blocs/suggestions_bloc.dart';
import 'package:movie_catalog/blocs/theme_bloc.dart';
import 'package:movie_catalog/config/flavor_config.dart';
import 'package:movie_catalog/config/keys.dart';
import 'package:movie_catalog/data/strings.dart';

import 'package:movie_catalog/models/models.dart';
import 'package:movie_catalog/screens/magic_search_screen.dart';
import 'package:movie_catalog/services/connectivity_service.dart';
import 'package:movie_catalog/services/link_service.dart';
import 'package:movie_catalog/widgets/movie/list/movie_grid.dart';

import 'package:movie_catalog/screens/search_screen.dart';
import 'package:movie_catalog/screens/suggestions_screen.dart';
import 'package:movie_catalog/widgets/api_not_available.dart';
import 'package:movie_catalog/widgets/movie/list/movie_list.dart';

import 'package:movie_catalog/widgets/no_internet_connection.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final bool darkModeEnabled;

  HomeScreen({@required this.darkModeEnabled});

  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  FirebaseMessaging _firebaseMessaging;

  final _connectivityService = ConnectivityService();
  // String result of the connection, gets updated by the subscription
  String _connectionStatus = 'Unknown';

  bool get online =>
      _connectionStatus == 'ConnectivityResult.none' ? false : true;

  final List<Tab> _tabs = [
    Tab(child: Text(Strings.tabLatest.toUpperCase())),
    Tab(child: Text(Strings.tabTopRated.toUpperCase())),
    Tab(child: Text(Strings.tabLibrary.toUpperCase())),
  ];

  bool gridEnabled = false;

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(vsync: this, length: _tabs.length);

    _initFirebaseMessaging();

    _initConnectivity();
    _connectivityService.connectivityStream.listen((ConnectivityResult result) {
      setState(() => _connectionStatus = result.toString());
    });

    FirebaseAdMob.instance.initialize(appId: Keys.theMovieDb);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: online ? _buildBody() : NoInternetConnection(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 5,
      title: Text(Strings.appName),
      actions: <Widget>[
        IconButton(
          icon: Icon(gridEnabled ? Icons.grid_on : Icons.grid_off, size: 20.0),
          onPressed: () {
            setState(() {
              gridEnabled = !gridEnabled;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            online
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Provider(
                        builder: (_) => SearchBloc(),
                        child: SearchScreen(),
                      ),
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

  Widget _buildBody() {
    final MovieBloc movieBloc = Provider.of<MovieBloc>(context);
    final LikedBloc likedBloc = Provider.of<LikedBloc>(context);

    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        _buildStreamBuilder(movieBloc, MovieType.latest),
        _buildStreamBuilder(movieBloc, MovieType.popular),
        StreamBuilder<List<Movie>>(
          stream: likedBloc.likedMoviesOut,
          builder: (BuildContext context, AsyncSnapshot<List<Movie>> snapshot) {
            return snapshot.hasError
                ? const ApiNotAvailable()
                : snapshot.hasData
                    ? gridEnabled
                        ? MovieGrid(movies: snapshot.data)
                        : MovieList(movies: snapshot.data)
                    : Center(
                        child: const CircularProgressIndicator(),
                      );
          },
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    ThemeBloc _themeBloc = Provider.of<ThemeBloc>(context);

    return SizedBox(
      width: MediaQuery.of(context).size.width / (3 / 2),
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              curve: Curves.easeIn,
              margin: EdgeInsets.only(bottom: 2.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.asset(
                    'assets/icon/icon.png',
                    fit: BoxFit.cover,
                    height: 75.0,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 10.0, 0.0, 10.0),
                    child: Text(
                      Strings.appName,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Theme.of(context).textTheme.headline.color,
                      ),
                    ),
                  )
                ],
              ),
              decoration: widget.darkModeEnabled
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Theme.of(context).primaryColorDark,
                          Theme.of(context).primaryColorLight,
                        ],
                      ),
                    )
                  : null,
            ),
            ListTile(
              leading: Icon(
                Icons.search,
                color: Theme.of(context).accentColor,
                size: 21.0,
              ),
              title: Text(Strings.search),
              onTap: () {
                online
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Provider(
                            builder: (_) => SearchBloc(),
                            child: SearchScreen(),
                          ),
                        ),
                      )
                    : print('Not online, searching is unavailable');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).accentColor,
                size: 21.0,
              ),
              title: Text(Strings.suggestions),
              onTap: () {
                online
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Provider(
                            child: SuggestionsScreen(),
                            builder: (_) => SuggestionsBloc(),
                          ),
                        ),
                      )
                    : print('Not online, suggestions are unavailable');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_enhance,
                color: Theme.of(context).accentColor,
                size: 21.0,
              ),
              title: Text(Strings.magic),
              onTap: () {
                online
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MagicSearchScreen()))
                    : print('Not online, magic search is unavailable');
              },
            ),
            FlavorConfig.of(context).flavorBuild == FlavorBuild.Free
                ? ListTile(
                    leading: Icon(
                      Icons.redeem,
                      color: Theme.of(context).accentColor,
                      size: 21.0,
                    ),
                    title: Text(Strings.buyProVersion),
                    onTap: () => _showProVersionDialog(),
                  )
                // Return empty widget
                : SizedBox(),
            Divider(
              color:
                  Theme.of(context).textTheme.headline.color.withOpacity(0.2),
              height: 1,
            ),
            ListTile(
                leading: Icon(
                  Icons.star,
                  color: Theme.of(context).accentColor,
                  size: 21,
                ),
                title: Text(Strings.rateInPlayStore),
                onTap: () {
                  String linkSuffix =
                      FlavorConfig.of(context).flavorBuild == FlavorBuild.Pro
                          ? '.pro'
                          : '';
                  LinkService.launchLink(
                      'https://play.google.com/store/apps/details?id=com.devrnt.moviecatalog$linkSuffix');
                }),
            ListTile(
              leading: Icon(
                Icons.reply,
                textDirection: TextDirection.rtl,
                color: Theme.of(context).accentColor,
                size: 21,
              ),
              title: Text('Feedback'),
              onTap: () {
                String mail = 'contact@jonasdevrient.be';
                String subject = 'Movie Catalog - Feedback';

                LinkService.launchLink('mailto:$mail?subject=$subject');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.share,
                color: Theme.of(context).accentColor,
                size: 21,
              ),
              title: Text('Share Movie Catalog'),
              onTap: () {
                LinkService.launchLink('https://app.jonasdevrient.be');
              },
            ),
            Divider(
              color:
                  Theme.of(context).textTheme.headline.color.withOpacity(0.2),
              height: 1,
            ),
            ListTile(
              leading: Icon(
                Icons.brightness_2,
                color: Theme.of(context).accentColor,
                size: 21,
              ),
              title: Text(Strings.darkMode),
              trailing: Switch(
                value: widget.darkModeEnabled,
                activeColor: Theme.of(context).accentColor,
                onChanged: _themeBloc.changeTheme.add,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> _initConnectivity() async {
    String connectionStatus;
    try {
      connectionStatus =
          (await _connectivityService.checkConnectivity()).toString();
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

  void _initFirebaseMessaging() {
    _firebaseMessaging = new FirebaseMessaging()
      ..configure(onMessage: (Map<String, dynamic> message) {
        _addNotificationAction(context, message);
        return null;
      }, onResume: (Map<String, dynamic> message) {
        _addNotificationAction(context, message);
        return null;
      }, onLaunch: (Map<String, dynamic> message) {
        _addNotificationAction(context, message);
        return null;
      });
    _firebaseMessaging.getToken().then((token) {
      print('Firebase Message token: $token');
    });
  }

  void _showProVersionDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).primaryColorLight,
            title: Text(Strings.buyProVersion),
            content: Text(
                '* There are no ads in the pro version\n* Be the first to receive new features'),
            actions: <Widget>[
              FlatButton(
                textColor: Theme.of(context).accentColor,
                child: Text('BUY IN PLAY STORE'),
                onPressed: () {
                  LinkService.launchLink(
                      'https://play.google.com/store/apps/details?id=com.devrnt.moviecatalog.pro');
                },
              )
            ],
          );
        });
  }

  StreamBuilder _buildStreamBuilder(MovieBloc movieBloc, MovieType movieType) {
    Stream<List<Movie>> stream;

    switch (movieType) {
      case MovieType.latest:
        stream = movieBloc.latestMoviesOut;
        break;
      case MovieType.popular:
        stream = movieBloc.popularMoviesOut;
        break;
      default:
    }

    return StreamBuilder<List<Movie>>(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<List<Movie>> snapshot) {
        return snapshot.hasError
            ? const ApiNotAvailable()
            : NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    // next page should be fetched
                    movieBloc.fetchNextPageIn.add(movieType);
                  }
                  return true;
                },
                child: snapshot.hasData
                    ? gridEnabled
                        ? MovieGrid(movies: snapshot.data)
                        : MovieList(movies: snapshot.data)
                    : Center(
                        child: const CircularProgressIndicator(),
                      ),
              );
      },
    );
  }

  void _addNotificationAction(
      BuildContext context, Map<String, dynamic> message) {
    // defined in Firebase Console
    final notificationAction = message['data']['notification_action'];
    print(notificationAction);

    switch (notificationAction) {
      case 'open_play_store':
        String linkSuffix =
            FlavorConfig.of(context).flavorBuild == FlavorBuild.Pro
                ? '.pro'
                : '';
        LinkService.launchLink(
            'https://play.google.com/store/apps/details?id=com.devrnt.moviecatalog$linkSuffix');
        break;
      default:
    }
  }
}
