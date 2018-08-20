import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/models/torrent.dart';

import 'package:url_launcher/url_launcher.dart';

class MovieDetails extends StatelessWidget {
  final Movie movie;

  MovieDetails({this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
      ),
      body: ListView(
        children: <Widget>[
          _buildBackgroundAndCover(),
          _buildYearAndTitle(),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 2 / 3,
              padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildTextIconWidget(
                      _fromMinutesToHourNotation(movie.runtime),
                      Icons.access_time,
                      Theme.of(context).accentColor),
                  _buildTextIconWidget(movie.rating.toString(), Icons.star,
                      Theme.of(context).accentColor)
                ],
              ),
            ),
          ),
          _buildSummary(),
          _buildGenres(),
          Container(
            margin: EdgeInsets.all(15.0),
            child: Row(
              children: _buildTorrents(
                  movie.torrents, Theme.of(context).accentColor, context),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBackgroundAndCover() {
    return Container(
      child: Stack(
        fit: StackFit.loose,
        alignment: Alignment(-0.90, 8.5),
        children: <Widget>[
          Container(
            height: 200.0,
            child: Image.network(
              movie.backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            child: Container(
              child: Image.network(
                movie.coverImage,
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
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
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
                      Text((torrent.size / 1048576).floor().toString() + ' MB')
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
                          Icons.high_quality,
                          color: iconColor,
                          size: 20.0,
                        ),
                      ),
                      Text(torrent.seeds.toString()),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                  ),
                  RaisedButton(
                    color: Colors.black26,
                    onPressed: () {
                      String magnetLink = constructMagnetLink(torrent, movie);
                      String link =
                          'magnet:?xt=urn:btih:024DC9289725FEB3CCE6A321EAFF344B05A70855&dn=Running+for+Grace+%282018%29+%5B720p%5D+%5BYTS.AG%5D&tr=udp%3A%2F%2Fglotorrents.pw%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fp4p.arenabg.ch%3A1337&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337';
                      _launchLink(magnetLink, context);
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.link),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 7.0)),
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

    return torrentsWidgets;
  }

  String _fromMinutesToHourNotation(int minutes) {
    int amountOfHours = (minutes / 60).floor();
    int amountOfMinutes = minutes % 60;

    String format =
        ' ' + amountOfHours.toString() + ':' + amountOfMinutes.toString();
    return format + 'h';
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
                Text(
                  'You could use BitTorrent.',
                  style: TextStyle(color: Colors.grey, fontSize: 14.0),
                )
              ],
            ),
          ),
          actions: <Widget>[
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
    String template = movie.titleLong +
        ' ' +
        '[' +
        torrent.quality +
        ']' +
        ' [YTS.AG]';
    // this Uri.encodeFull does not provide all the needed replaces
    String encoded = Uri.encodeFull(template);

    encoded = encoded
        .replaceAll(('%20'), '+')
        .replaceAll('(', '%28')
        .replaceAll(')', '%29');
    return encoded;
  }
}
