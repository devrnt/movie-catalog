import 'package:flutter/material.dart';
import 'package:movie_catalog/models/cast.dart';
import 'package:movie_catalog/utils/widget_helper.dart';

class CastItem extends StatelessWidget {
  final Cast cast;

  CastItem({this.cast});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(cast.profilePath),
      padding: const EdgeInsets.only(right: 25),
      child: Row(
        children: <Widget>[
          InkWell(
            child: ClipOval(
              clipBehavior: Clip.antiAlias,
              child: FadeInImage.assetNetwork(
                width: 75,
                height: 75,
                fadeInDuration: Duration(milliseconds: 550),
                image: 'https://image.tmdb.org/t/p/w500/${cast.profilePath}',
                placeholder: 'assets/images/cover_placeholder.jpg',
                fit: BoxFit.cover,
              ),
            ),
            onTap: () => WidgetHelper.showFullScreenImageDialog(
                context, 'https://image.tmdb.org/t/p/w500/${cast.profilePath}'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(cast.character,
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(fontWeight: FontWeight.w500)),
                ),
                Text(cast.name,
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(fontWeight: FontWeight.w300))
              ],
            ),
          )
        ],
      ),
    );
  }
}
