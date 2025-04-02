// ignore_for_file: file_names

import 'package:movie_app/model/Country.dart';
import 'package:movie_app/model/Episode.dart';
import 'package:movie_app/model/genre.dart';

class Movie {
  final int movieId;
  final String name;
  final String description;
  final String studio;
  final String imageUrl;
  final double rating;
  final String? timeupdate;
  final int duration;
  final bool isMovie;
  final bool state;
  final bool premium;
  final String? trailerUrl;
  final int view;
  final Country? country;
  final List<Genre> genres;
  final List<Episode> episodes;

  Movie({
    required this.movieId,
    required this.name,
    required this.description,
    required this.studio,
    required this.imageUrl,
    required this.rating,
    this.timeupdate,
    required this.duration,
    required this.isMovie,
    required this.state,
    required this.premium,
    this.trailerUrl,
    required this.view,
    this.country,
    required this.genres,
    required this.episodes,
  });
  int get currentEpisodes =>
      episodes.where((episode) => episode.state == true).length;
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      movieId: json['movieId'],
      name: json['name'],
      description: json['description'] ?? '',
      studio: json['studio'],
      imageUrl: json['imageUrl'],
      rating: (json['average'] ?? 0).toDouble(),
      timeupdate: json['timeupdate'],
      duration: json['duration'] ?? 0,
      isMovie: json['ismovie'] ?? false,
      state: json['state'] ?? false,
      premium: json['premium'] ?? false,
      trailerUrl: json['trailerUrl'],
      view: json['view'] ?? 0,
      country:
          json['country'] != null ? Country.fromJson(json['country']) : null,
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e))
              .toList() ??
          [],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((g) => Genre.fromJson(g))
              .toList() ??
          [],
    );
  }
}
