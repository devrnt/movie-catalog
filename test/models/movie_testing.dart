import 'package:flutter_test/flutter_test.dart';
import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/models/torrent.dart';

void main() {
  Movie movie;

  setUp(() {
    movie = new Movie(
        8521,
        'Pina',
        'Pina long',
        2011,
        'In modern dance since the 1970s, few choreographers have had more influence in the medium than the late Pina Bausch. This film explores the life and work of this artist of movement while we see her company perform her most notable creations where basic things like water, dirt and even gravity take on otherworldly qualities in their dancing.',
        'random',
        ['Documentary', 'Horror'],
        7.7,
        'https://yts.am/movie/pina-2011',
        'tt1440266',
        92,
        'English',
        'https://yts.am/assets/images/movies/pina_2011/background.jpg',
        'https://yts.am/assets/images/movies/pina_2011/small-cover.jpg',
        'https://yts.am/assets/images/movies/pina_2011/medium-cover.jpg',
        'https://yts.am/assets/images/movies/pina_2011/large-cover.jpg',
        [
          new Torrent(
              'https://yts.am/assets/images/movies/pina_2011/large-cover.jpg',
              '90CBAC6473DD54F9911E4ADBE0C0CE7C0A2DE6FC',
              '720p',
              931649290,
              new DateTime.now(),
              74,
              57),
          new Torrent(
              'https://yts.am/assets/images/movies/pina_2011/large-cover.jpg',
              '90CBAC6473DD54F9911E4ADBE0C0CE7C0A2DE6FC',
              '720p',
              931649290,
              new DateTime.now(),
              74,
              57),
        ]);
  });

  test('fromJson() after toJson() returns movie type', () {
    var json = movie.toJson();

    Movie outJson = Movie.fromJson(json);
    expect(movie.runtime, outJson.runtime);
  });

  test('fromJson() after toJson() returns new movie with zero torrents', () {
    var json = movie.toJson();

    Movie outJson = Movie.fromJson(json);
    expect(0, outJson.torrents.length);
  });
}
