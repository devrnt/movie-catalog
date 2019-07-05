import 'package:flutter/material.dart';
import 'package:movie_catalog/bloc/liked_bloc.dart';
import 'package:movie_catalog/models/models.dart';
import 'package:movie_catalog/screens/movie_details_screen.dart';
import 'package:provider/provider.dart';

class MovieCardGrid extends StatelessWidget {
  final Movie movie;

  MovieCardGrid({this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              maintainState: true,
              builder: (context) => MovieDetails(
                    movie: movie,
                    likedMoviesStream:
                        Provider.of<LikedBloc>(context).likedMoviesOut,
                  ),
            ),
          ),
      child: _buildCard(context: context),
    );
  }

  Widget _buildCard({BuildContext context}) {
    return Padding(
      key: Key(movie.id.toString()),
      padding: const EdgeInsets.fromLTRB(2, 1, 2, 1),
      child: Card(
        elevation: 4,
        color: Theme.of(context).primaryColorLight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: FadeInImage.assetNetwork(
                fadeInDuration: const Duration(milliseconds: 550),
                image: movie.coverImageMedium ??
                    movie.coverImageLarge ??
                    'assets/images/cover_placeholder.jpg',
                placeholder: 'assets/images/cover_placeholder.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Padding(
                    padding: const EdgeInsets.only(bottom: 1.75),
                  ),
                  Text(
                    movie.year.toString(),
                    style: TextStyle(
                        color:
                            Theme.of(context).iconTheme.color.withOpacity(0.6),
                        fontSize: 13.0),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
