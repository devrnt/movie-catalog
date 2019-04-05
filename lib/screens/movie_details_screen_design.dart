import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/bloc/liked_bloc.dart';

import 'package:movie_catalog/bloc/liked_movie_bloc.dart';
import 'package:movie_catalog/bloc/movie_bloc.dart';
import 'package:movie_catalog/models/subtitle.dart';
import 'package:movie_catalog/services/storage_service.dart';
import 'package:movie_catalog/services/subtitle_service.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/models/torrent.dart';

import 'package:permission_handler/permission_handler.dart';

class MovieDetailsDesign extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final Movie movie;
  final Stream<List<Movie>> likedMoviesStream;

  MovieDetailsDesign({
    this.movie,
    @required this.likedMoviesStream,
  });

  @override
  MovieDetailsState createState() => new MovieDetailsState();

  Widget _buildGenres() {
    final String genreString = movie.genres.length > 1
        ? 'Genres:'.toUpperCase()
        : 'Genre:'.toUpperCase();
    String genres = '';

    String formattedGenres = '';
    if (movie.genres.length > 0) {
      movie.genres.forEach((genre) {
        genres += (genre + ', ');
      });
      formattedGenres = genres.substring(0, genres.length - 2);
    } else {
      formattedGenres = 'No genres';
    }

    // remove the last comma
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 17.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            genreString,
            style: TextStyle(
                color: Colors.white30,
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
              color: Colors.white.withOpacity(0.8),
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTorrents(
      List<Torrent> torrents, Color iconColor, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 15.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
          Widget>[
        Text(
          'Torrents:'.toUpperCase(),
          style: TextStyle(
              color: Colors.white30,
              fontWeight: FontWeight.w500,
              fontSize: 14.0),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 10.0),
        ),
        Container(
          child: Row(
            children: torrents.map((torrent) {
              return Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: RaisedButton(
                  elevation: 4.0,
                  color: Theme.of(context).primaryColorLight,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 17.0, horizontal: 15.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          torrent.quality,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                        ),
                        Text(
                          (torrent.size / 1048576).floor().toString() + 'MB',
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 3.0),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            ),
                            Row(
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
                          ],
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    String magnetLink = constructMagnetLink(torrent, movie);
                    _launchLink(magnetLink, context);
                  },
                ),
              );
            }).toList(),
          ),
        )
      ]),
    );
    // List<Widget> torrentsWidgets = new List();
    // if (torrents.isEmpty) {
    //   torrentsWidgets = [
    //     Text(
    //       'No torrent available at the moment.',
    //       style: TextStyle(color: Colors.white70),
    //     )
    //   ];
    // } else {
    //   torrents.forEach((torrent) {
    //     torrentsWidgets.add(
    //       Expanded(
    //         child: Center(
    //           child: Container(
    //             padding: EdgeInsets.all(17.0),
    //             child: Column(
    //               children: <Widget>[
    //                 Row(
    //                   children: <Widget>[
    //                     Padding(
    //                       padding: EdgeInsets.only(right: 7.0),
    //                       child: Icon(
    //                         Icons.high_quality,
    //                         color: iconColor,
    //                         size: 20.0,
    //                       ),
    //                     ),
    //                     Text(torrent.quality),
    //                   ],
    //                 ),
    //                 Padding(
    //                   padding: EdgeInsets.symmetric(vertical: 5.0),
    //                 ),
    //                 Row(
    //                   children: <Widget>[
    //                     Padding(
    //                       padding: EdgeInsets.only(right: 7.0),
    //                       child: Icon(
    //                         Icons.folder_open,
    //                         color: iconColor,
    //                         size: 20.0,
    //                       ),
    //                     ),
    //                     Text((torrent.size / 1048576).floor().toString() + 'MB')
    //                   ],
    //                 ),
    //                 Padding(
    //                   padding: EdgeInsets.symmetric(vertical: 5.0),
    //                 ),
    //                 Row(
    //                   children: <Widget>[
    //                     Padding(
    //                       padding: EdgeInsets.only(right: 7.0),
    //                       child: Icon(
    //                         Icons.arrow_upward,
    //                         color: iconColor,
    //                         size: 22.0,
    //                       ),
    //                     ),
    //                     Text(torrent.seeds.toString()),
    //                   ],
    //                 ),
    //                 Padding(
    //                   padding: EdgeInsets.symmetric(vertical: 5.0),
    //                 ),
    //                 Row(
    //                   children: <Widget>[
    //                     Padding(
    //                       padding: EdgeInsets.only(right: 7.0),
    //                       child: Icon(
    //                         Icons.arrow_downward,
    //                         color: iconColor,
    //                         size: 22.0,
    //                       ),
    //                     ),
    //                     Text(torrent.peers.toString()),
    //                   ],
    //                 ),
    //                 Padding(
    //                   padding: EdgeInsets.symmetric(vertical: 12.0),
    //                 ),
    //                 RaisedButton(
    //                   color: Theme.of(context).accentColor,
    //                   onPressed: () {
    //                     String magnetLink = constructMagnetLink(torrent, movie);
    //                     _launchLink(magnetLink, context);
    //                   },
    //                   child: Row(
    //                     children: <Widget>[
    //                       Icon(Icons.link),
    //                       Padding(
    //                           padding: EdgeInsets.symmetric(horizontal: 7.0)),
    //                       Text('Magnet'.toUpperCase())
    //                     ],
    //                   ),
    //                 )
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //     );
    //   });
    // }
    // return torrentsWidgets;
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

class MovieDetailsState extends State<MovieDetailsDesign> {
  StorageService _storageService;
  SubtitleService _subtitleService;
  Subtitle _selectedSubtitle;
  Future<List<Subtitle>> _subtitles;

  // permissions
  PermissionGroup permission = PermissionGroup.storage;

  bool liked = false;
  LikedMovieBloc _bloc;

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
                tooltip: 'Add movie to your library',
                iconSize: 20.0,
                icon: Icon(
                  snapshot.data ? Icons.favorite : Icons.favorite_border,
                  color: snapshot.data ? Colors.white : Colors.grey,
                ),
                onPressed: () {
                  print(snapshot.data);
                  if (snapshot.data) {
                    bloc.removeLikedIn.add(widget.movie);

                    _showSnackBar(
                        title: 'Removed from your library',
                        color: Colors.red,
                        icon: Icons.delete);
                  } else {
                    bloc.addLikedIn.add(widget.movie);
                    _showSnackBar(
                        title: 'Added to your library',
                        color: Colors.green,
                        icon: Icons.done);
                  }
                  // if (!liked) {
                  //   setState(() {
                  //     _storageService.writeToFile(widget.movie);
                  //     liked = !liked;
                  //   });
                  //   _showSnackBar(
                  //       title: 'Added to your library',
                  //       color: Colors.green,
                  //       icon: Icons.done);
                  // } else {
                  //   setState(() {
                  //     _storageService.removeFromFile(widget.movie);
                  //     liked = !liked;
                  //   });

                  //   _showSnackBar(
                  //       title: 'Removed from your library',
                  //       color: Colors.red,
                  //       icon: Icons.delete);
                },
              );
            },
          ),
          // IconButton(
          //   tooltip: 'Add movie to your library',
          //   iconSize: 20.0,
          //   icon: Icon(
          //     liked ? Icons.favorite : Icons.favorite_border,
          //     color: liked ? Colors.white : Colors.grey,
          //   ),
          //   onPressed: () {
          //     if (!liked) {
          //       setState(() {
          //         _storageService.writeToFile(widget.movie);
          //         liked = !liked;
          //       });
          //       _showSnackBar(
          //           title: 'Added to your library',
          //           color: Colors.green,
          //           icon: Icons.done);
          //     } else {
          //       setState(() {
          //         _storageService.removeFromFile(widget.movie);
          //         liked = !liked;
          //       });

          //       _showSnackBar(
          //           title: 'Removed from your library',
          //           color: Colors.red,
          //           icon: Icons.delete);
          //     }
          //     // save the movie to the liked list
          //   },
          // )
        ],
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            _buildBackgroundAndCover(),
            // widget.µ_buildYearAndTitle(),
            _buildLabels(),
            // Center(
            //   child: Container(
            //     width: MediaQuery.of(context).size.width * 2 / 3,
            //     padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 10.0),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //       children: <Widget>[
            //         widget._buildTextIconWidget(
            //             widget._fromMinutesToHourNotation(widget.movie.runtime),
            //             Icons.access_time,
            //             Theme.of(context).accentColor),
            //         widget._buildTextIconWidget(widget.movie.rating.toString(),
            //             Icons.star, Theme.of(context).accentColor)
            //       ],
            //     ),
            //   ),
            // ),
            _buildSummary(),
            widget._buildGenres(),
            _buildSubtitles(),
            widget._buildTorrents(
                widget.movie.torrents, Theme.of(context).accentColor, context),
            _buildLinks(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _storageService = new StorageService();
    _subtitleService = new SubtitleService();
    _createBloc();
    _subtitles = _subtitleService.getSubtitles(widget.movie.imdbCode);

    _storageService.liked(widget.movie).then((result) {
      setState(() {
        liked = result;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _bloc.dispose();
    super.dispose();
  }

  void _createBloc() {
    _bloc = new LikedMovieBloc(movie: widget.movie);
    // Simple pipe from the stream that lists all the favorites into
    // the BLoC that processes THIS particular movie
    _subscription = widget.likedMoviesStream.listen(_bloc.likedMovieIn.add);
  }

  Widget _buildSummary() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Summary'.toUpperCase(),
            style: TextStyle(
                color: Colors.white30,
                fontWeight: FontWeight.w500,
                fontSize: 14.0),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
          ),
          Text(
            widget.movie.summary,
            style: TextStyle(
                color: Colors.white.withOpacity(0.80),
                height: 1.55,
                fontSize: 14.5,
                wordSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  void _showSnackBar({String title, Color color, IconData icon}) {
    final snackbar = SnackBar(
      content: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: Icon(
              icon,
              size: 20.0,
            ),
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

  Widget _buildSubtitles() {
    final String subtitleString = 'subtitles:'.toUpperCase();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            subtitleString,
            style: TextStyle(
                color: Colors.white30,
                fontWeight: FontWeight.w500,
                fontSize: 14.0),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
          ),
          FutureBuilder(
              future: _subtitles,
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                if (snapshot.hasData) {
                  if (snapshot.data.isEmpty) {
                    return Text(
                      'No subtitles available',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.80),
                      ),
                    );
                  } else {
                    return _buildSubtitleDropDown(snapshot.data);
                  }
                } else {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
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
                            padding: EdgeInsets.only(left: 12.0),
                          ),
                          Text(sub.language),
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
    if (await checkPermission()) {
      await _subtitleService.downloadSubtitle(url);
      _showSnackBar(
          color: Colors.green,
          icon: Icons.done,
          title: 'Subtitle downloaded in your Downloads folder');
    } else {
      await requestPermission();
      if (await checkPermission() == false) {
        _showSnackBar(
            color: Colors.amber[700],
            icon: Icons.warning,
            title: 'Please accept the permission');
        //
      } else {
        _downloadFile(url);
      }
    }
  }

  requestPermission() async {
    await PermissionHandler().requestPermissions([permission]);
  }

  Future<bool> checkPermission() async {
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
                  //color: Colors.lightGreen
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
                FadeInImage.assetNetwork(
                  image: '${widget.movie.coverImageLarge}',
                  // 'https://www.countryflags.io/${sub.countryCode}/flat/32.png',
                  width: 93.0,
                  placeholder: 'assets/images/cover_placeholder.jpg',
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
                            color: Colors.grey[500],
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        widget.movie.title,
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.w600),
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

  _buildLabels() {
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
                    style: TextStyle(fontSize: 10.0, color: Colors.white30),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.0),
                  ),
                  Text(
                    widget._fromMinutesToHourNotation(widget.movie.runtime),
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white.withOpacity(0.75),
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
                      fontSize: 10.0,
                      color: Colors.white30,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.0),
                  ),
                  Text(
                    widget.movie.language,
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white.withOpacity(0.75),
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Rating'.toUpperCase(),
                    style: TextStyle(fontSize: 10.0, color: Colors.white30),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.0),
                  ),
                  Text(
                    widget.movie.rating.toString(),
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white.withOpacity(0.75),
                        fontWeight: FontWeight.w400),
                  ),
                ],
              )
            ],
          ),
        ));
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
                color: Colors.white30,
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
                  widget._launchLink(url, context);
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 7.0),
              ),
              RaisedButton(
                color: Colors.white,
                child: Text(
                  'IMDB'.toUpperCase(),
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  String url =
                      'https://www.imdb.com/title/${widget.movie.imdbCode}';
                  widget._launchLink(url, context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
