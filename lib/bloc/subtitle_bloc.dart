import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:movie_catalog/models/models.dart';
import 'package:movie_catalog/services/subtitle_service.dart';
import 'package:rxdart/rxdart.dart';

import 'package:movie_catalog/bloc/bloc_base.dart';

/// Fetches the movie details for the passed [movie]
class SubtitleBloc extends BlocBase {
  Movie movie;
  List<Subtitle> _subtitles;

  BehaviorSubject<List<Subtitle>> _subtitleController = new BehaviorSubject();
  Stream<List<Subtitle>> get subtitlesOut => _subtitleController.stream;

  final SubtitleService _subtitleService = new SubtitleService();

  SubtitleBloc({@required this.movie}) {
    movie = movie;
    _getMovieSubtitles();
  }

  void _getMovieSubtitles() async {
    _subtitles = await _subtitleService.getSubtitles(movie.imdbCode);

    _subtitleController.sink.add(_subtitles);
  }
  
  // This function is added to the bloc but is in fact no stream
  // Moved it to here so the details screen does not need to depend on SubtitleService
  Future<File> downloadSubtitle(String url) async {
    return await _subtitleService.downloadSubtitle(url);
  }

  @override
  void dispose() async {
    // Discards all data on the stream, but signals when it's done or an error occurred.
    await _subtitleController.drain();
    _subtitleController.close();
  }
}
