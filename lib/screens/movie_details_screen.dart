import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_catalog/services/storage_service.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/models/torrent.dart';

class MovieDetails extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Movie movie;

  MovieDetails({this.movie});

  @override
  MovieDetailsState createState() {
    return new MovieDetailsState();
  }

  Widget _buildBackgroundAndCover() {
    return Container(
      child: Stack(
        fit: StackFit.loose,
        alignment: Alignment(-0.90, 8.5),
        children: <Widget>[
          Container(
            height: 200.0,
            width: double.infinity, // max width
            child: FadeInImage.assetNetwork(
              fadeInDuration: Duration(milliseconds: 350),
              image: movie.backgroundImage,
              placeholder: 'assets/images/cover_placeholder.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            child: Container(
              child: FadeInImage.assetNetwork(
                fadeInDuration: Duration(milliseconds: 100),
                fadeInCurve: Curves.linear,
                image: movie.coverImageLarge,
                placeholder: 'assets/images/cover_placeholder.jpg',
                fit: BoxFit.cover,
                height: 170.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearAndTitle() {
    return Container(
      width: 100.0,
      padding: EdgeInsets.fromLTRB(150.0, 30.0, 70.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            movie.year.toString(),
            style: TextStyle(fontSize: 15.0, color: Colors.grey),
          ),
          Text(
            movie.title,
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      child: Text(
        movie.summary,
        style: TextStyle(color: Colors.grey[500], height: 1.25),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
    );
  }

  Widget _buildTextIconWidget(String text, IconData icon, Color color) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Icon(
            icon,
            size: 14.0,
            color: color,
          ),
        ),
        Text(text),
      ],
    );
  }

  Widget _buildGenres() {
    final String genreString = 'Genres:'.toUpperCase();
    String genres = '';

    String formattedGenres = '';
    if (movie.genres.length > 0) {
      movie.genres.forEach((genre) {
        genres += (genre + ', ');
      });
      formattedGenres = genres.substring(0, genres.length - 2);
    } else {
      formattedGenres = '';
    }

    // remove the last comma
    return Container(
      margin: EdgeInsets.all(15.0),
      child: Row(
        children: <Widget>[
          Text(
            genreString,
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.only(left: 7.0),
            child: Text(
              formattedGenres,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildTorrents(
      List<Torrent> torrents, Color iconColor, BuildContext context) {
    List<Widget> torrentsWidgets = new List();
    if (torrents.isEmpty) {
      torrentsWidgets = [
        Text(
          'No torrent available at the moment.',
          style: TextStyle(color: Colors.white70),
        )
      ];
    } else {
      torrents.forEach((torrent) {
        torrentsWidgets.add(
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(17.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 7.0),
                          child: Icon(
                            Icons.high_quality,
                            color: iconColor,
                            size: 20.0,
                          ),
                        ),
                        Text(torrent.quality),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 7.0),
                          child: Icon(
                            Icons.folder_open,
                            color: iconColor,
                            size: 20.0,
                          ),
                        ),
                        Text((torrent.size / 1048576).floor().toString() + 'MB')
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 7.0),
                          child: Icon(
                            Icons.arrow_upward,
                            color: iconColor,
                            size: 22.0,
                          ),
                        ),
                        Text(torrent.seeds.toString()),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 7.0),
                          child: Icon(
                            Icons.arrow_downward,
                            color: iconColor,
                            size: 22.0,
                          ),
                        ),
                        Text(torrent.peers.toString()),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    RaisedButton(
                      color: Theme.of(context).accentColor,
                      onPressed: () {
                        String magnetLink = constructMagnetLink(torrent, movie);
                        _launchLink(magnetLink, context);
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.link),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 7.0)),
                          Text('Magnet'.toUpperCase())
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      });
    }
    return torrentsWidgets;
  }

  String _fromMinutesToHourNotation(int minutes) {
    int amountOfHours = (minutes / 60).floor();
    int amountOfMinutes = minutes % 60;

    String amountOfMinutesFormatted;
    if (amountOfMinutes.toString().length < 2) {
      amountOfMinutesFormatted = '0$amountOfMinutes';
    } else {
      amountOfMinutesFormatted = amountOfMinutes.toString();
    }

    return ' $amountOfHours:${amountOfMinutesFormatted}h';
  }

  void _launchLink(String link, BuildContext context) async {
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      _showAlert(context);
    }
  }

  Future<Null> _showAlert(BuildContext context) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Torrent app installed'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please install a torrent client.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('PLAY STORE'),
              textColor: Colors.grey,
              onPressed: () => _launchLink(
                  'https://play.google.com/store/apps/details?id=com.bittorrent.client',
                  context),
            ),
            FlatButton(
              child: Text('CLOSE'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  String constructMagnetLink(Torrent torrent, Movie movie) {
    // trackers provided by the yify api
    List<String> trackers = [
      'udp://open.demonii.com:1337',
      'udp://tracker.istole.it:80',
      'http://tracker.yify-torrents.com/announce',
      'udp://tracker.publicbt.com:80',
      'udp://tracker.openbittorrent.com:80',
      'udp://tracker.coppersurfer.tk:6969',
      'udp://exodus.desync.com:6969',
      'http://exodus.desync.com:6969/announce'
    ];

    String template = 'magnet:?xt=urn:btih:' +
        torrent.hash +
        '&dn=' +
        encodeMovie(movie, torrent) +
        '&tr=' +
        trackers.join('&tr=');
    return template;
  }

  String encodeMovie(Movie movie, Torrent torrent) {
    String template =
        movie.titleLong + ' ' + '[' + torrent.quality + ']' + ' [YTS.AG]';
    // this Uri.encodeFull does not provide all the needed replaces
    String encoded = Uri.encodeFull(template);

    encoded = encoded
        .replaceAll(('%20'), '+')
        .replaceAll('(', '%28')
        .replaceAll(')', '%29');
    return encoded;
  }
}

class MovieDetailsState extends State<MovieDetails> {
  StorageService _storageService;
  bool liked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget._scaffoldKey,
      appBar: AppBar(
        title: Text(widget.movie.title, style: TextStyle(fontSize: 17.0)),
        actions: <Widget>[
          IconButton(
            iconSize: 20.0,
            icon: Icon(
              liked ? Icons.favorite : Icons.favorite_border,
              color: liked ? Theme.of(context).accentColor : Colors.grey,
            ),
            onPressed: () {
              if (!liked) {
                setState(() {
                  _storageService.writeToFile(widget.movie);
                  liked = !liked;
                });
                _showSnackBar(
                    title: 'Added to your library',
                    color: Theme.of(context).accentColor,
                    icon: Icons.done);
              } else {
                setState(() {
                  _storageService.removeFromFile(widget.movie);
                  liked = !liked;
                });

                _showSnackBar(
                    title: 'Removed from your library',
                    color: Colors.red,
                    icon: Icons.delete);
              }
              // save the movie to the liked list
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          widget._buildBackgroundAndCover(),
          widget._buildYearAndTitle(),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 2 / 3,
              padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  widget._buildTextIconWidget(
                      widget._fromMinutesToHourNotation(widget.movie.runtime),
                      Icons.access_time,
                      Theme.of(context).accentColor),
                  widget._buildTextIconWidget(widget.movie.rating.toString(),
                      Icons.star, Theme.of(context).accentColor)
                ],
              ),
            ),
          ),
          widget._buildSummary(),
          widget._buildGenres(),
          Container(
            margin: EdgeInsets.all(15.0),
            child: Row(
              children: widget._buildTorrents(widget.movie.torrents,
                  Theme.of(context).accentColor, context),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _storageService = new StorageService();
    _storageService.liked(widget.movie).then((result) {
      setState(() {
        liked = result;
      });
    });
  }

  void _showSnackBar({String title, Color color, IconData icon}) {
    final snackbar = SnackBar(
      content: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: Icon(icon, size: 20.0,),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      duration: Duration(seconds: 2),
      backgroundColor: color,
    );
    widget._scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
