import 'package:movie_catalog/models/torrent.dart';

class Movie {
  int id;
  String title;
  String titleLong;
  int year;
  String summary;
  String ytTrailerCode;
  List<dynamic> genres;
  num rating;
  String url;
  String imdbCode;
  int runtime;
  String language;
  // Images
  String backgroundImage;
  String coverImageSmall;
  String coverImageMedium;
  String coverImageLarge;
  List<Torrent> torrents;

  Movie(
      this.id,
      this.title,
      this.titleLong,
      this.year,
      this.summary,
      this.ytTrailerCode,
      this.genres,
      this.rating,
      this.url,
      this.imdbCode,
      this.runtime,
      this.language,
      this.backgroundImage,
      this.coverImageSmall,
      this.coverImageMedium,
      this.coverImageLarge,
      this.torrents);

  factory Movie.fromJson(Map<String, dynamic> json) {
    // It's possible that there are no terrents provided yet
    List<dynamic> jsonTorrentList = json['torrents'] as List;
    List<Torrent> listTorrents;

    if (jsonTorrentList != null) {
      listTorrents =
          jsonTorrentList.map<Torrent>((t) => Torrent.fromJson(t)).toList();
    } else {
      listTorrents = new List();
    }

    List jsonGenresList = json['genres'] as List;

    // It's possible that there are no genres provided
    if (jsonGenresList == null) {
      jsonGenresList = [];
    } else {
      new List<String>.from(jsonGenresList);
    }

    num formattedRating = json['rating'];
    formattedRating = formattedRating?.toDouble();

    return Movie(
        json['id'] as int,
        json['title'] as String,
        json['title_long'] as String,
        json['year'] as int,
        json['summary'] as String,
        json['yt_trailer_code'] as String,
        jsonGenresList,
        formattedRating,
        json['url'] as String,
        json['imdb_code'] as String,
        json['runtime'] as int,
        json['language'] as String,
        json['background_image_original'] as String,
        json['small_cover_image'] as String,
        json['medium_cover_image'] as String,
        json['large_cover_image'] as String,
        listTorrents);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'title_long': titleLong,
        'year': year,
        'summary': summary,
        'yt_trailer_code': ytTrailerCode,
        'genres': genres,
        'rating': rating,
        'url': url,
        'imdb_code': imdbCode,
        'runtime': runtime,
        'language': language,
        'background_image_original': backgroundImage,
        'medium_cover_image': coverImageMedium,
        'large_cover_image': coverImageLarge,
        'torrents': null
      };
}
