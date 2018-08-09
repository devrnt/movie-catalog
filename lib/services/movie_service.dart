import 'package:movie_catalog/data/dummy_data.dart';
import 'package:movie_catalog/models/movie.dart';

class MovieService {
  List<Movie> listOfMovies;
  MovieService() {
    listOfMovies = movies;
  }

  Movie getMovie(int id) {
    return listOfMovies.where((movie) => movie.id == id).first;
  }
}
