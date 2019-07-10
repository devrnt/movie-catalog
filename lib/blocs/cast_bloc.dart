import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:movie_catalog/blocs/bloc_base.dart';
import 'package:movie_catalog/models/models.dart';
import 'package:movie_catalog/services/movie_service.dart';
import 'package:rxdart/rxdart.dart';

import 'package:http/http.dart' as http;

/// Fetches the cast for the passed [movie]
class CastBloc extends BlocBase {
  Movie movie;

  BehaviorSubject<List<Cast>> _castController = new BehaviorSubject();
  Stream<List<Cast>> get castOut => _castController.stream;

  final MovieService _movieService = new MovieService();

  List<Cast> _cast = [];

  CastBloc({@required this.movie}) {
    _getCast();
  }

  void _getCast() async {
    _cast = await _movieService.fetchCast(http.Client(), movie.imdbCode);

    _castController.sink.add(UnmodifiableListView(_cast));
  }

  @override
  void dispose() {
    _castController.close();
  }
}
