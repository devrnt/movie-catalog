import 'package:movie_catalog/models/torrent.dart';

class Movie {
  int id;
  String title;
  int year;
  String summary;
  List<String> genres;
  double rating;
  String url;
  String imdbCode;
  int runtime;
  // Images
  String backgroundImage;
  String coverImage;
  List<Torrent> torrents;

  Movie(
      this.id,
      this.title,
      this.year,
      this.summary,
      this.genres,
      this.rating,
      this.url,
      this.imdbCode,
      this.runtime,
      this.backgroundImage,
      this.coverImage,
      this.torrents);
}
