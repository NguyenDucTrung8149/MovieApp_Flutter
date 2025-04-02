import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:movie_app/Api/ApiService.dart';
import 'package:movie_app/global/constants/image_routes.dart';
import 'package:movie_app/model/Comment.dart';
import 'package:movie_app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentSection extends StatefulWidget {
  final int episodeId;
  final int movieId;

  CommentSection({
    required this.episodeId,
    required this.movieId,
  });

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 3; // Giá trị đánh giá mặc định từ 1 đến 5.
  bool _isSubmitting = false;
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoString = prefs.getString('userInfo');
    if (userInfoString != null) {
      setState(() {
        _userInfo = jsonDecode(userInfoString);
      });
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập nội dung bình luận!')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ApiService.addComment(
        username: _userInfo!['username'].toString(),
        episodeId: widget.episodeId,
        content: _commentController.text,
        rating: _rating,
        movieId: widget.movieId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gửi bình luận thành công!')),
      );

      _commentController.clear();
      setState(() {
        _rating = 3;
      });

      // Làm mới danh sách bình luận
      setState(() {});
    } catch (e) {
      print('Gửi bình luận thất bại: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _deleteComment(int commentId) async {
    try {
      await ApiService.deleteComment(
        commentId: commentId,
        movieId: widget.movieId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa bình luận thành công!')),
      );

      // Làm mới danh sách bình luận sau khi xóa
      setState(() {});
    } catch (e) {
      print('Xóa bình luận thất bại: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa bình luận thất bại!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<Comment>>(
            future: ApiService.fetchComments(widget.episodeId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text('Chưa có bình luận nào.',
                        style: TextStyle(
                            color: AppDynamicColorBuilder.getGrey800AndGrey300(
                                context))));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final comment = snapshot.data![index];
                    final isCurrentUser =
                        comment.user.userName == _userInfo?['username'];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: comment.user.imageUrl != null
                            ? NetworkImage(
                                'http://192.168.0.100:8080${comment.user.imageUrl}',
                              )
                            : AssetImage(AppImagesRoute.userProfileImage),
                      ),
                      title: Text(
                        comment.user.name,
                        style: TextStyle(
                            color: AppDynamicColorBuilder.getGrey800AndGrey300(
                                context)),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment.content,
                              style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 5),
                          Text("Đánh giá: ${comment.rating}/5",
                              style: TextStyle(color: Colors.orange)),
                        ],
                      ),
                      trailing: isCurrentUser
                          ? IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteComment(comment.id),
                            )
                          : null,
                    );
                  },
                );
              }
            },
          ),
        ),
        Divider(color: Colors.grey),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: "Nhập bình luận...",
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(
                      color:
                          AppDynamicColorBuilder.getGrey800AndGrey300(context)),
                ),
              ),
              SizedBox(width: 8),
              DropdownButton<int>(
                value: _rating,
                items: List.generate(5, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex <= index ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 20,
                        );
                      }),
                    ),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _rating = value!;
                  });
                },
                dropdownColor:
                    AppDynamicColorBuilder.getGrey100AndDark2(context),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 8),
              _isSubmitting
                  ? CircularProgressIndicator()
                  : IconButton(
                      icon: Icon(Icons.send, color: Colors.redAccent),
                      onPressed: _submitComment,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
