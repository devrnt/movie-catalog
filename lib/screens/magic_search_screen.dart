import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movie_catalog/data/strings.dart';
import 'package:movie_catalog/models/models.dart';
import 'package:movie_catalog/services/movie_service.dart';
import 'package:http/http.dart' as http;
import 'package:movie_catalog/widgets/movie/list/movie_list.dart';

class MagicSearchScreen extends StatefulWidget {
  @override
  _MagicSearchScreenState createState() => _MagicSearchScreenState();
}

class _MagicSearchScreenState extends State<MagicSearchScreen> {
  List<Movie> _movies = [];
  String _searchWord;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.magic),
      ),
      body: _searchWord == null
          ? Center(child: Text('Take a picture'))
          : _movies.isEmpty ? noMagicSearchResults : MovieList(movies: _movies),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget get noMagicSearchResults {
    return Center(
      child: Text(
        'No search results found for $_searchWord\nTake another picture',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget get floatingActionButton {
    return FloatingActionButton(
      onPressed: _getImageAndLabel,
      tooltip: 'Pick an image',
      child: Icon(Icons.add_a_photo),
    );
  }

  void _getImageAndLabel() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.camera);

    final image = FirebaseVisionImage.fromFile(imageFile);
    final imageLabeler = FirebaseVision.instance.imageLabeler();
    final imageLabels = await imageLabeler.processImage(image);
    _searchWord = imageLabels.first.text;

    final movies = await MovieService()
        .fetchMoviesByQuery(http.Client(), _searchWord.replaceAll(' ', '+'), 1);

    setState(() {
      _movies = movies;
    });
  }
}
