import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/bloc/cast_bloc.dart';
import 'package:movie_catalog/bloc/liked_bloc.dart';

import 'package:movie_catalog/bloc/liked_movie_bloc.dart';
import 'package:movie_catalog/bloc/movie_details_bloc.dart';
import 'package:movie_catalog/data/strings.dart';
import 'package:movie_catalog/models/cast.dart';
import 'package:movie_catalog/models/subtitle.dart';
import 'package:movie_catalog/services/subtitle_service.dart';
import 'package:movie_catalog/utils/torrent_builder.dart';
import 'package:movie_catalog/utils/widget_helper.dart';
import 'package:movie_catalog/widgets/api_not_available.dart';
import 'package:movie_catalog/widgets/cast_item.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/models/torrent.dart';

import 'package:permission_handler/permission_handler.dart';

class MovieDetails extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final Movie movie;
  final Stream<List<Movie>> likedMoviesStream;

  MovieDetails({
    @required this.movie,
    @required this.likedMoviesStream,
  });

  @override
  MovieDetailsState createState() => new MovieDetailsState();
}

class MovieDetailsState extends State<MovieDetails> {
  SubtitleService _subtitleService;
  Subtitle _selectedSubtitle;
  Future<List<Subtitle>> _subtitles;

  // permissions
  PermissionGroup permission = PermissionGroup.storage;

  bool liked = false;
  LikedMovieBloc _bloc;
  CastBloc _castBloc;
  MovieDetailsBloc _movieDetailsBloc;

  StreamSubscription _subscription;

  @override
  Widget build(BuildContext context) {
    final LikedBloc bloc = BlocProvider.of<LikedBloc>(context);

    return Scaffold(
      key: widget._scaffoldKey,
      appBar: AppBar(
        title: Text(widget.movie.title, style: TextStyle(fontSize: 17.0)),
        actions: <Widget>[
          StreamBuilder<bool>(
            stream: _bloc.isLikedOut,
            initialData: false,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              return IconButton(
                tooltip: Strings.addMovieToLikes,
                iconSize: 20.0,
                icon: snapshot.data == true
                    ? Icon(Icons.favorite, color: Theme.of(context).accentColor)
                    : Icon(Icons.favorite_border,
                        color: Theme.of(context)
                            .textTheme
                            .subtitle
                            .color
                            .withOpacity(0.7)),
                onPressed: () {
                  if (snapshot.data == true) {
                    bloc.removeLikedIn.add(widget.movie);
                    WidgetHelper.showSnackbar(context,
                        Strings.removedMovieToLikes, Colors.red, Icons.delete);
                  } else {
                    bloc.addLikedIn.add(widget.movie);
                    WidgetHelper.showSnackbar(context,
                        Strings.addedMovieToLikes, Colors.green, Icons.done);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
          stream: _movieDetailsBloc.movieDetailsOut,
          builder: (BuildContext context, AsyncSnapshot<Movie> snapshot) {
            return Container(
              child: ListView(
                children: <Widget>[
                  _buildBackgroundAndCover(),
                  _buildLabels(),
                  _buildSummary(),
                  _buildGenres(),
                  _buildCast(),
                  _buildSubtitles(),
                  _buildTorrents(
                      widget.movie.torrents, Theme.of(context).accentColor),
                  _buildLinks(),
                ],
              ),
            );
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    _subtitleService = new SubtitleService();
    _createBloc();
    _subtitles = _subtitleService.getSubtitles(widget.movie.imdbCode);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _bloc.dispose();
    _movieDetailsBloc.dispose();
    super.dispose();
  }

  void _createBloc() {
    _bloc = new LikedMovieBloc(movie: widget.movie);
    _castBloc = new CastBloc(movie: widget.movie);
    _movieDetailsBloc = new MovieDetailsBloc(movie: widget.movie);
    // Simple pipe from the stream that lists all the favorites into
    // the BLoC that processes this particular movie
    _subscription = widget.likedMoviesStream.listen(_bloc.likedMovieIn.add);
  }

  Widget _buildSummary() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              'Summary'.toUpperCase(),
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .subhead
                      .color
                      .withOpacity(0.3),
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0),
            ),
          ),
          Text(
            widget.movie.summary,
            style: TextStyle(
                color:
                    Theme.of(context).textTheme.subhead.color.withOpacity(0.8),
                height: 1.50,
                fontSize: 14.5,
                wordSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitles() {
    final String subtitleString = 'subtitles'.toUpperCase();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              subtitleString,
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .subhead
                      .color
                      .withOpacity(0.3),
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0),
            ),
          ),
          FutureBuilder(
              future: _subtitles,
              builder: (context, snapshot) {
                if (snapshot.hasError) ApiNotAvailable();
                if (snapshot.hasData) {
                  if (snapshot.data.isEmpty) {
                    return Text(
                      Strings.noSubtitlesAvailable,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context)
                            .textTheme
                            .subhead
                            .color
                            .withOpacity(0.8),
                      ),
                    );
                  } else {
                    return _buildSubtitleDropDown(snapshot.data);
                  }
                } else {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: SizedBox(
                      height: 12.0,
                      width: 12.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }

  Widget _buildSubtitleDropDown(List<Subtitle> subtitles) {
    return Row(
      children: <Widget>[
        DropdownButton(
          style: TextStyle(fontSize: 16.0),
          value: _selectedSubtitle,
          hint: Text('Language'),
          onChanged: (Subtitle subtitle) {
            print(subtitle.language);
            setState(() {
              _selectedSubtitle = subtitle;
            });
          },
          items: subtitles
              .map(
                (sub) => DropdownMenuItem(
                      value: sub,
                      child: Row(
                        children: <Widget>[
                          FadeInImage.assetNetwork(
                            image:
                                // 'https://www.geoips.com/assets/img/flag/128/${sub.countryCode.toLowerCase()}.png',
                                'https://www.countryflags.io/${sub.countryCode}/flat/32.png',
                            height: 22.0,
                            placeholder: 'assets/images/flag_placeholder.jpg',
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Text(
                              sub.language,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .color
                                    .withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              )
              .toList(),
        ),
        _selectedSubtitle != null
            ? Container(
                alignment: Alignment.center,
                child: IconButton(
                  icon: Icon(
                    Icons.save_alt,
                    color: Theme.of(context).accentColor,
                  ),
                  onPressed: () {
                    _downloadFile(_selectedSubtitle.downloadUrl);
                  },
                ),
              )
            : Container(),
      ],
    );
  }

  void _downloadFile(String url) async {
    if (await _checkPermission()) {
      await _subtitleService.downloadSubtitle(url);
      WidgetHelper.showSnackbar(
          context, Strings.subtitleDownloaded, Colors.green, Icons.done);
    } else {
      await _requestPermission();
      if (await _checkPermission() == false) {
        WidgetHelper.showSnackbar(context, Strings.acceptPermission,
            Colors.amber[700], Icons.warning);
      } else {
        _downloadFile(url);
      }
    }
  }

  _requestPermission() async {
    await PermissionHandler().requestPermissions([permission]);
  }

  Future<bool> _checkPermission() async {
    PermissionStatus permissionStatus =
        await PermissionHandler().checkPermissionStatus(permission);
    return permissionStatus == PermissionStatus.granted;
  }

  Widget _buildBackgroundAndCover() {
    return Container(
      height: 260.0,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: <Widget>[
          Stack(
            fit: StackFit.expand,
            children: [
              Container(
                height: 260.0,
                width: double.infinity, // max width
                child: FadeInImage.assetNetwork(
                  fadeInDuration: Duration(milliseconds: 350),
                  image: widget.movie.backgroundImage,
                  placeholder: 'assets/images/cover_placeholder.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.87, 1.5),
                    end: Alignment(1.0, 0.0),
                    stops: [0.20, 0.55, 0.75],
                    colors: [
                      Theme.of(context).primaryColorDark,
                      Theme.of(context).primaryColorDark.withOpacity(0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                InkWell(
                  onTap: () => WidgetHelper.showFullScreenImageDialog(
                      context, '${widget.movie.coverImageLarge}'),
                  child: FadeInImage.assetNetwork(
                    image: '${widget.movie.coverImageLarge}',
                    width: 93.0,
                    placeholder: 'assets/images/cover_placeholder.jpg',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        widget.movie.year.toString().toUpperCase(),
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.5),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        widget.movie.title,
                        style: Theme.of(context).textTheme.display2.copyWith(
                            color: Theme.of(context).textTheme.display1.color,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabels() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 50.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Length'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Theme.of(context)
                          .textTheme
                          .subhead
                          .color
                          .withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.0),
                  ),
                  Text(
                    _fromMinutesToHourNotation(widget.movie.runtime),
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Theme.of(context)
                            .textTheme
                            .subhead
                            .color
                            .withOpacity(0.8),
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Language'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Theme.of(context)
                          .textTheme
                          .subhead
                          .color
                          .withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.0),
                  ),
                  Text(
                    widget.movie.language,
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Theme.of(context)
                            .textTheme
                            .subhead
                            .color
                            .withOpacity(0.8),
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Rating'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Theme.of(context)
                          .textTheme
                          .subhead
                          .color
                          .withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.0),
                  ),
                  Text(
                    widget.movie.rating.toString(),
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Theme.of(context)
                            .textTheme
                            .subhead
                            .color
                            .withOpacity(0.8),
                        fontWeight: FontWeight.w400),
                  ),
                ],
              )
            ],
          ),
        ));
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

    return '$amountOfHours:${amountOfMinutesFormatted}h';
  }

  Widget _buildLinks() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Links'.toUpperCase(),
            style: TextStyle(
                color:
                    Theme.of(context).textTheme.subhead.color.withOpacity(0.3),
                fontWeight: FontWeight.w500,
                fontSize: 14.0),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                color: Theme.of(context).primaryColorLight,
                child: Text('Trailer'.toUpperCase()),
                onPressed: () {
                  String url =
                      'https://www.youtube.com/watch?v=${widget.movie.ytTrailerCode}';
                  _launchLink(url, context);
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 7.0),
              ),
              RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  'IMDB'.toUpperCase(),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
                onPressed: () {
                  String url =
                      'https://www.imdb.com/title/${widget.movie.imdbCode}';
                  _launchLink(url, context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _launchLink(String link, BuildContext context) async {
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      _showAlert(context);
    }
  }

  Widget _buildTorrents(List<Torrent> torrents, Color iconColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 15.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text(
                'Torrents'.toUpperCase(),
                style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .subhead
                        .color
                        .withOpacity(0.3),
                    fontWeight: FontWeight.w500,
                    fontSize: 14.0),
              ),
            ),
            Container(
              child: Wrap(
                runSpacing: 10.0,
                spacing: 12.0,
                direction: Axis.horizontal,
                children: torrents.map((torrent) {
                  return _buildTorrentItem(torrent, iconColor);
                }).toList(),
              ),
            ),
          ]),
    );
  }

  Future<Null> _showAlert(BuildContext context) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).primaryColorLight,
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

  Widget _buildGenres() {
    final String genreString = widget.movie.genres.length > 1
        ? 'Genres'.toUpperCase()
        : 'Genre'.toUpperCase();
    String genres = '';

    String formattedGenres = '';
    if (widget.movie.genres.isNotEmpty) {
      widget.movie.genres.forEach((genre) {
        genres += (genre + ', ');
      });
      // remove the last comma
      formattedGenres = genres.substring(0, genres.length - 2);
    } else {
      formattedGenres = 'No genres';
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 17.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            genreString,
            style: TextStyle(
                color:
                    Theme.of(context).textTheme.subhead.color.withOpacity(0.3),
                fontWeight: FontWeight.w500,
                fontSize: 14.0),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
          ),
          Text(
            formattedGenres,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).textTheme.subhead.color.withOpacity(0.8),
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTorrentItem(Torrent torrent, Color iconColor) {
    return RaisedButton(
      elevation: 4.0,
      color: Theme.of(context).primaryColorLight,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 17.0, horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            torrent.type != null ?Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '${torrent.type.substring(0, 1).toUpperCase()}${torrent.type.substring(1)}',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).accentColor),
              ),
            ):SizedBox(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                torrent.quality,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 3.0),
              child: Text(
                (torrent.size / 1048576).floor().toString() + 'MB',
                style: TextStyle(fontWeight: FontWeight.w300),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 2.0),
                      child: Icon(
                        Icons.arrow_upward,
                        color: iconColor,
                        size: 15.0,
                      ),
                    ),
                    Text(torrent.seeds.toString()),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 2.0),
                        child: Icon(
                          Icons.arrow_downward,
                          color: iconColor,
                          size: 15.0,
                        ),
                      ),
                      Text(torrent.peers.toString()),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onPressed: () {
        String magnetLink =
            TorrentBuilder.constructMagnetLink(torrent, widget.movie);
        _launchLink(magnetLink, context);
      },
    );
  }

  Widget _buildCast() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 17.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              'Cast'.toUpperCase(),
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .subhead
                      .color
                      .withOpacity(0.3),
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0),
            ),
          ),
          Container(
            height: 80,
            alignment: Alignment.centerLeft,
            child: StreamBuilder(
              stream: _castBloc.castOut,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child:
                          Text('Something happened while fetching the cast'));
                }
                if (snapshot.hasData) {
                  List<Cast> cast = snapshot.data;
                  return ListView(
                    children:
                        cast.map((actor) => CastItem(cast: actor)).toList(),
                    scrollDirection: Axis.horizontal,
                  );
                } else {
                  return SizedBox(
                    height: 12.0,
                    width: 12.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
