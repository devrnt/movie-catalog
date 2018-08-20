import 'package:movie_catalog/models/torrent.dart';

class Movie {
  int id;
  String title;
  String titleLong;
  int year;
  String summary;
  List<dynamic> genres;
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
      this.titleLong,
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

  factory Movie.fromJson(Map<String, dynamic> json) {
    var list = json['torrents'] as List;
    List<Torrent> listTorrents = list.map((i) => Torrent.fromJson(i)).toList();
    var genres = json['genres'];
    // some movies have no genres (genres = null)
    // this is an extra check
    List<String> genresList = json['genres'] != null
        ? new List<String>.from(genres)
        : new List<String>();

    num formattedRating =
        json['rating'].runtimeType == double ? json['rating'] : 0.0;

    return Movie(
        json['id'] as int,
        json['title'] as String,
        json['title_long'] as String,
        json['year'] as int,
        json['summary'] as String,
        genresList,
        formattedRating,
        json['url'] as String,
        json['imdb_code'] as String,
        json['runtime'] as int,
        json['background_image_original'] as String,
        json['large_cover_image'] as String,
        listTorrents);
  }
}
