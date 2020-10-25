import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;

import 'package:html/parser.dart';
import 'package:movie_catalog/models/models.dart';
import 'package:movie_catalog/services/storage/liked_movies_service.dart';

// WEB CRAWLER - DOM MIGHT CHANGE IN FUTURE
class SubtitleService {
  http.Client _client;
  LikedMoviesService _storageService;
  String _baseUrl = 'https://www.yifysubtitles.org/movie-imdb';
  String _url;
  // static var httpClient = new HttpClient(); is for original download code

  SubtitleService() {
    _client = new http.Client();
    _storageService = new LikedMoviesService();
  }

  Future<Document> _fetchDOM(String imdbCode) async {
    _url = '$_baseUrl/$imdbCode';
    final response = await _client.get(_url);
    final document = parse(response.body);
    return document;
  }

  Future<List<Subtitle>> getSubtitles(String imdbCode) async {
    bool subtitlesAvailable = false;

    Document document = await _fetchDOM(imdbCode);

    subtitlesAvailable =
        document.getElementsByTagName('tbody').isEmpty ? false : true;

    List<Subtitle> subtitles = [];

    if (subtitlesAvailable) {
      List<Element> startElement = document.getElementsByTagName('tbody');

      subtitles = startElement.first.children.map((row) {
        return new Subtitle(
            // id: int.parse(elem.parent.parent.attributes['data-id']),
            language: row.getElementsByClassName('sub-lang').first.text,
            downloadUrl: row
                .getElementsByClassName('flag-cell')
                .first
                .nextElementSibling
                .children
                .first
                .attributes['href'],
            rating: int.parse(row
                .getElementsByClassName('rating-cell')
                .first
                .firstChild
                .text));
      }).toList();
    }
    // filter the big subtitle list
    // Why? performance and quality
    return subtitles.where((sub) => sub.rating > 0).toList();
  }

  Future<File> downloadSubtitle(String url) async {
    var req = await _client.get(Uri.parse(url));
    var bytes = req.bodyBytes;

    String path = await _storageService.downloadsPath;

    String fileName = url
        .replaceFirst('https://www.yifysubtitles.org/subtitle/', '')
        .replaceFirst('.zip', '')
        .replaceFirst('-yify-', '');

    File file = new File('$path/$fileName');
    file.writeAsBytesSync(bytes);

    Archive archive = new ZipDecoder().decodeBytes(file.readAsBytesSync());

    file.deleteSync();

    // Extract the contents of the Zip archive to disk.
    for (ArchiveFile file in archive) {
      String filename = file.name;
      if (file.isFile) {
        List<int> data = file.content;
        return new File('$path/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    }
    return null;
  }
}
