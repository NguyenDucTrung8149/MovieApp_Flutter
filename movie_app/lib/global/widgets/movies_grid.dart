import 'package:flutter/material.dart';
import 'package:movie_app/model/Movie.dart';

import 'movie_card_item.dart';

class MoviesGrid extends StatelessWidget {
  final List<Movie> movies;

  const MoviesGrid({
    super.key,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(child: Text('No movies found')),
      );
    }

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) => MovieCardItem(
          movie: movies[index],
          needsSpacing: false,
        ),
        childCount: movies.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 2 / 2.6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        crossAxisCount: 2,
      ),
    );
  }
}
