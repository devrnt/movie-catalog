import 'package:flutter_test/flutter_test.dart';
import 'package:movie_catalog/models/genres.dart';
import 'package:movie_catalog/models/quality.dart';

void main() {
  // Genres
  test('Give all genres returns all the genres', () {
    expect(25, Genres.values.length);
  });
  test('Give first genre returns genre \'all\'', () {
    expect(Genres.all, Genres.values.first);
  });

  // Qualities
  test('Give all qualities returns all the qualities', () {
    expect(4, Qualities.values.length);
  });
  test('Give first quality returns quality \'qAll\'', () {
    expect(Qualities.qAll, Qualities.values.first);
  });
}
