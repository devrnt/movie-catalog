import 'package:movie_catalog/models/models.dart';

class TorrentBuilder {
  static String constructMagnetLink(Torrent torrent, Movie movie) {
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

  static String encodeMovie(Movie movie, Torrent torrent) {
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
