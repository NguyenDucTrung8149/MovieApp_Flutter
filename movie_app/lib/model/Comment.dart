import 'package:movie_app/model/User.dart';

class Comment {
  final int id;
  final String content;
  final String timeStamp;
  final int rating;
  final User user;

  Comment({
    required this.id,
    required this.content,
    required this.timeStamp,
    required this.rating,
    required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      timeStamp: json['timeStamp'],
      rating: json['rating'],
      user: User.fromJson(json['user']),
    );
  }
}
