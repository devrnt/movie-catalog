import 'dart:async';

import 'package:flutter/material.dart';

import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/bloc/search_bloc.dart';
import 'package:movie_catalog/data/strings.dart';

import 'package:movie_catalog/models/movie.dart';
import 'package:movie_catalog/screens/movie_list.dart';

import 'package:movie_catalog/screens/filter_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchBloc _bloc;

  TextEditingController _searchQueryController = new TextEditingController();
  Timer _debounce;

  @override
  void initState() {
    super.initState();
    _searchQueryController.addListener(_textInputListener);
    _bloc = BlocProvider.of<SearchBloc>(context);
  }

  @override
  void dispose() {
    _searchQueryController.removeListener(_textInputListener);
    _searchQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchInput(),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FilterScreen(),
                ),
              );
            },
          )
        ],
      ),
      body: Container(
        child: StreamBuilder<bool>(
          stream: _bloc.loadingOut,
          builder: (context, snapshot) {
            bool loading = snapshot?.data ?? false;
            return loading
                ? Center(child: CircularProgressIndicator())
                : StreamBuilder<List<Movie>>(
                    stream: _bloc.searchResultsOut,
                    initialData: [],
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Movie>> snapshot) {
                      return snapshot.hasError
                          ? Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.error),
                                  Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 3.0)),
                                  Text(Strings.serverUnavailable),
                                ],
                              ),
                            )
                          : snapshot.hasData
                              ? snapshot.data.isEmpty
                                  ? _searchQueryController.text.isEmpty
                                      ? Center(
                                          child: Text(Strings.searchForAMovie))
                                      : Center(
                                          child: Text(Strings.noSearchResults))
                                  : MovieList(movies: snapshot.data)
                              : Center(child: CircularProgressIndicator());
                    },
                  );
          },
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: TextField(
        autofocus: true,
        controller: _searchQueryController,
        decoration: new InputDecoration(
          border: InputBorder.none,
          hintText: 'Title, year...',
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
            child: Icon(
              Icons.search,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  void _textInputListener() {
    if (_debounce?.isActive ?? false) {
      _debounce.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _bloc.searchTextIn.add(_searchQueryController.text);
    });
  }
}
