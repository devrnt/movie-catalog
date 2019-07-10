import 'package:flutter/material.dart';

import 'package:movie_catalog/blocs/filter_bloc.dart';
import 'package:movie_catalog/models/models.dart';
import 'package:movie_catalog/widgets/api_not_available.dart';

import 'package:movie_catalog/widgets/movie/list/movie_grid.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  FilterBloc _filterBloc;

  List<DropdownMenuItem<Genres>> genres = Genres.values
      .map((enumVal) => DropdownMenuItem(
            child: Text(_formatGenreEnumValue(enumVal)),
            value: enumVal,
          ))
      .toList();

  List<DropdownMenuItem<Qualities>> qualities = Qualities.values
      .map((enumVal) => DropdownMenuItem(
            child: Text(_formatQualityEnumValue(enumVal)),
            value: enumVal,
          ))
      .toList();

  List<DropdownMenuItem<int>> ratings = List.generate(
      10,
      (index) => DropdownMenuItem(
            child: Text('$index+'),
            value: index,
          ));

  Genres selectedGenre;
  Qualities selectedQuality;
  int selectedRating = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter by'),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
            margin: EdgeInsets.all(15.0),
            child: ListView(
              children: <Widget>[
                _buildDropDownMenu(
                    value: selectedGenre,
                    items: genres,
                    hint: 'Genre',
                    defaultText: selectedGenre == null
                        ? 'All'
                        : _formatGenreEnumValue(selectedGenre)),
                _buildDropDownMenu(
                    value: selectedQuality,
                    items: qualities,
                    hint: 'Quality',
                    defaultText: selectedQuality == null
                        ? 'All'
                        : _formatQualityEnumValue(selectedQuality)),
                InputDecorator(
                  decoration: InputDecoration(
                      labelText: 'Rating',
                      suffixIcon: Chip(
                        label: Text('${selectedRating.toString()}+'),
                      )),
                  child: Slider(
                    label: selectedRating?.toString() ?? 'Rating: 0+',
                    min: 0.0,
                    max: 9.0,
                    divisions: 9,
                    inactiveColor: Colors.grey,
                    activeColor: Theme.of(context).accentColor,
                    onChanged: (double value) {
                      setState(() {
                        selectedRating = value.toInt();
                      });
                    },
                    value: selectedRating?.toDouble() ?? 0.0,
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorLight,
                          child: Text('CLEAR ALL'),
                          onPressed: () {
                            setState(() {
                              selectedGenre = null;
                              selectedQuality = null;
                              selectedRating = 0;
                            });
                          },
                        ),
                      ),
                      RaisedButton(
                        color: Theme.of(context).accentColor,
                        child: Text('SEARCH'),
                        onPressed: () {
                          _searchByConfig();
                        },
                      ),
                    ])
              ],
            )),
      ),
    );
  }

  Widget _buildDropDownMenu(
      {dynamic value,
      List<DropdownMenuItem> items,
      String hint,
      String defaultText}) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: hint,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
            hint: Text(defaultText),
            // value: value,
            isDense: true,
            onChanged: (val) {
              setState(() {
                switch (val.runtimeType) {
                  case Genres:
                    setState(() {
                      selectedGenre = val;
                    });
                    break;
                  case Qualities:
                    setState(() {
                      selectedQuality = val;
                    });
                    break;
                  case int:
                    setState(() {
                      selectedRating = val;
                    });
                    break;

                  default:
                }
                value = val;
              });
            },
            items: items),
      ),
    );
  }

  void _searchByConfig() {
    String genre;
    String quality;
    String rating;
    if (selectedGenre == null) {
      genre = '';
    } else {
      genre = _formatGenreEnumValue(selectedGenre);
    }
    if (selectedQuality == null) {
      quality = '';
    } else {
      quality = _formatQualityEnumValue(selectedQuality);
    }
    if (selectedRating == null) {
      rating = '';
    } else {
      rating = selectedRating.toString();
    }
    _filterBloc = new FilterBloc(
      currentPage: 1,
      genre: genre,
      quality: quality,
      rating: rating,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Filter results'),
          ),
          body: StreamBuilder<List<Movie>>(
            stream: _filterBloc.filteredMoviesOut,
            builder: (context, snapshot) {
              if (snapshot.hasError) return ApiNotAvailable();
              return snapshot.hasData
                  ? MovieGrid(movies: snapshot.data)
                  : Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}

String _formatGenreEnumValue(Genres enumVal) {
  String formatted = enumVal.toString().trim().split('.')[1];
  String camelCase = '${formatted[0].toUpperCase()}${formatted.substring(1)}';
  camelCase = camelCase.replaceAll('_', '-');
  return camelCase;
}

String _formatQualityEnumValue(Qualities enumVal) {
  String formatted = enumVal.toString().trim().split('.')[1].substring(1);
  String camelCase = '${formatted[0].toUpperCase()}${formatted.substring(1)}';
  return camelCase;
}
