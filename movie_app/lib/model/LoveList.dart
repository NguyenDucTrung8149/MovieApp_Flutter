import 'Movie.dart';

class LoveList {
  final int id;
  final DateTime ngayLuu;
  final Movie movie;

  LoveList({
    required this.id,
    required this.ngayLuu,
    required this.movie,
  });

  factory LoveList.fromJson(Map<String, dynamic> json) {
    return LoveList(
      id: json['id'],
      ngayLuu: DateTime.parse(json['ngayluu']),
      movie: Movie.fromJson(json['movie']),
    );
  }
}
