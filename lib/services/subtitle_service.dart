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
  String _baseUrl = 'https://www.yifysubtitles.com/movie-imdb';
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
      List<Element> startElement = document.getElementsByClassName('sub-lang');

      subtitles = startElement.map((elem) {
        return new Subtitle(
            // id: int.parse(elem.parent.parent.attributes['data-id']),
            language: elem.text,
            downloadUrl:
                elem.parent.nextElementSibling.firstChild.attributes['href'],
            rating:
                int.parse(elem.parent.previousElementSibling.firstChild.text));
      }).toList();
    }
    // filter the big subtitle list
    // Why? performance and quality
    return subtitles.where((sub) => sub.rating > 0).toList();
  }

  Future<File> downloadSubtitle(String url) async {
    var req = await _client.get(Uri.parse(url));
    var bytes = req.bodyBytes;

    // THIS IS THE ORIGAL I wrote it with http package; (above)
    // var request = await httpClient.getUrl(Uri.parse(url));
    // var response = await request.close();
    // var bytes = await consolidateHttpClientResponseBytes(response);

    String path = await _storageService.downloadsPath;

    String fileName = url
        .replaceFirst('https://www.yifysubtitles.com/subtitle/', '')
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
