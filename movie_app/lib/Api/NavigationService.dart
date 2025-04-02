import 'package:flutter/material.dart';
import 'package:movie_app/global/widgets/MovieDetailScreen.dart';
import 'package:movie_app/model/Movie.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static void checkNavigator() {
    if (navigatorKey.currentState != null) {
      print("Navigator is not null");
    } else {
      print("Navigator is null");
    }
  }

  static void navigateToMovieDetail(Movie movie) {
    checkNavigator();
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(
          movie: movie,
          genre: movie.genres,
        ),
      ),
    );
  }
}
