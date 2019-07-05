import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:debug_mode/debug_mode.dart';

import 'package:movie_catalog/bloc/liked_bloc.dart';
import 'package:movie_catalog/config/flavor_config.dart';
import 'package:movie_catalog/config/keys.dart';
import 'package:movie_catalog/models/models.dart';
import 'package:movie_catalog/screens/movie_details_screen.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  static final MobileAdTargetingInfo targetingInfo =
      new MobileAdTargetingInfo(childDirected: false, testDevices: [
    'FCF4540BC12076FAF1490A4C6AC03170'
  ], keywords: [
    'Movie',
    'Movies',
    'Cinema',
    'Download',
    'Yify',
    'YTS',
    'Watching',
    'Netflix',
    'Popcorn Time'
  ]);

  final InterstitialAd interstitialAd = new InterstitialAd(
      adUnitId: Keys.addUnitId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print('InterstitialAd event is $event');
      });

  MovieCard({this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: new Key(movie.id.toString()),
      onTap: () {
        if (FlavorConfig.of(context).flavorBuild == FlavorBuild.Free &&
            !DebugMode.isInDebugMode) {
          // we could add another flag to display even less ads
          bool displayAdFlag = new Random().nextBool();
          if (displayAdFlag) {
            interstitialAd
              ..load()
              ..show();
          }
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            maintainState: true,
            builder: (context) => MovieDetails(
                  movie: movie,
                  likedMoviesStream:
                      Provider.of<LikedBloc>(context).likedMoviesOut,
                ),
          ),
        );
      },
      child: _buildCard(context: context),
    );
  }

  Widget _buildCard({BuildContext context}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 3, 10, 0),
      child: Card(
        elevation: 2,
        color: Theme.of(context).primaryColorLight,
        child: Row(
          children: <Widget>[
            _buildCover(),
            _buildLabels(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    return Container(
      height: 175,
      padding: const EdgeInsets.fromLTRB(8, 8, 15, 8),
      child: FadeInImage.assetNetwork(
        fadeInDuration: const Duration(milliseconds: 750),
        image: movie.coverImageMedium ??
            movie.coverImageLarge ??
            'assets/images/cover_placeholder.jpg',
        placeholder: 'assets/images/cover_placeholder.jpg',
        fit: BoxFit.fill,
        width: 105.0,
      ),
    );
  }

  Widget _buildLabels(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildYearLabel(),
          _buildTitleLabel(context),
          _buildRating(context),
          _buildCategoriesLabel(),
        ],
      ),
    );
  }

  Widget _buildYearLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        movie.year.toString().toUpperCase(),
        style: TextStyle(
            color: Colors.grey[500],
            fontSize: 15.0,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTitleLabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 7, 5,7),
      child: Text(movie.title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(context)
              .textTheme
              .subhead
              .copyWith(fontSize: 18.0, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildCategoriesLabel() {
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        formattedGenres,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: TextStyle(
            color: Colors.grey[500],
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1),
      ),
    );
  }

  Widget _buildRating(BuildContext context) {
    double amountOfStars = movie.rating / 2;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: SmoothStarRating(
                allowHalfRating: true,
                starCount: 5,
                rating: amountOfStars,
                size: 17,
                color: Theme.of(context).accentColor,
                borderColor: Colors.grey[500]),
          ),
          Container(
            padding: const EdgeInsets.only(left: 7),
            alignment: Alignment.center,
            height: 20,
            child:
                Text('${movie.rating}', style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }
}
