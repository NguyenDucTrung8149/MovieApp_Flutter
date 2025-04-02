import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_app/Api/ApiService.dart';
import 'package:movie_app/global/widgets/MovieDetailScreen.dart';
import 'package:movie_app/model/Movie.dart';
import 'package:movie_app/model/genre.dart';
import 'package:movie_app/theme/app_colors.dart';

class MovieCardItem extends StatelessWidget {
  final Movie movie;
  final bool needsSpacing;

  const MovieCardItem({
    super.key,
    required this.movie,
    required this.needsSpacing,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        try {
          Movie? detailedMovie =
              await ApiService.fetchMovieDetails(movie.movieId);
          List<Genre>? genre = await ApiService().fetchGenres(movie.movieId);

          if (detailedMovie != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen(
                  movie: detailedMovie,
                  genre: genre,
                ),
              ),
            );
          } else {
            // Show an error message if the movie is not found
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Movie not found.')),
            );
          }
        } catch (e) {
          // Handle connection or other errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch movie details.')),
          );
        }
      },
      child: Container(
        width: 150,
        margin: needsSpacing ? EdgeInsets.only(left: 10, right: 0) : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(movie.imageUrl), // Use NetworkImage
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  movie.rating.toStringAsFixed(1),
                  style: theme.textTheme.labelSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.name,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${movie.currentEpisodes}/${movie.duration} Tập',
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
