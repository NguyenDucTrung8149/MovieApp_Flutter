import 'package:flutter/material.dart';
import 'package:movie_app/Api/ApiService.dart';
import 'package:movie_app/home/widgets/movie_list.dart';
import 'package:movie_app/home/widgets/movie_list_title.dart';
import 'package:movie_app/home/widgets/top_header.dart';
import 'package:movie_app/model/Movie.dart';
import 'package:movie_app/theme_notifier.dart';


import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> _movies;
  late Future<List<Movie>> _moviesTop;
  @override
  void initState() {
    super.initState();
    _movies = ApiService.fetchMovies();
    _moviesTop = ApiService.fetchTopMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier themeNotifier, child) => Scaffold(
        body: CustomScrollView(
          slivers: [
            TopHeader(),
            MovieListTitle(title: 'Top 10 Movies '),
            MovieList(movies: _moviesTop),
            MovieListTitle(title: 'New Releases'),
            MovieList(movies: _movies),
            SliverPadding(padding: EdgeInsets.only(top: 24)),
          ],
        ),
      ),
    );
  }
}
