import 'package:flutter/material.dart';
import 'package:movie_app/global/widgets/movie_card_item.dart';
import 'package:movie_app/model/Movie.dart';



class MovieList extends StatelessWidget {
  final Future<List<Movie>> movies;

  const MovieList({
    super.key,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
     return FutureBuilder<List<Movie>>(
      future: movies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('No movies found')),
          );
        } else {
          final movieList = snapshot.data!;
          return SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: movieList.length,
                itemBuilder: (context, index) => MovieCardItem(
                  movie: movieList[index],
                  needsSpacing: true,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
