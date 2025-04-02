// ignore_for_file: unnecessary_string_interpolations

import 'dart:async';
import 'dart:convert';

import 'package:better_player_enhanced/better_player.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/Api/ApiService.dart';
import 'package:movie_app/global/widgets/CommentSection.dart';
import 'package:movie_app/model/Movie.dart';
import 'package:movie_app/model/genre.dart';
import 'package:movie_app/provider/download_provider.dart';
import 'package:movie_app/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final List<Genre> genre;

  MovieDetailScreen({required this.movie, required this.genre});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen>
    with SingleTickerProviderStateMixin {
  late BetterPlayerController _betterPlayerController;
  late TabController _tabController;
  bool _viewIncremented = false;
  int? _currentEpisodeId;
  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
    _currentEpisodeId = widget.movie.episodes.first.id;
    if (widget.movie.episodes.isNotEmpty &&
        widget.movie.episodes.first.episodeLink != null &&
        widget.movie.episodes.first.episodeLink!.isNotEmpty) {
      String initialVideoUrl = widget.movie.episodes.first.episodeLink!;

      Map<String, String> resolutions = _generateResolutions(initialVideoUrl);

      BetterPlayerConfiguration betterPlayerConfiguration =
          BetterPlayerConfiguration(
        autoPlay: false,
        looping: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSubtitles: true,
          enablePlaybackSpeed: true,
          enableProgressText: false,
          controlBarColor: const Color.fromARGB(0, 0, 0, 0),
          iconsColor: Colors.white,
          enableQualities: true,
        ),
      );
      _betterPlayerController =
          BetterPlayerController(betterPlayerConfiguration);

      String defaultResolutionUrl =
          _generateDefaultResolutionUrl(initialVideoUrl, "480p");

      _betterPlayerController.setupDataSource(
        BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          defaultResolutionUrl,
          resolutions: resolutions,
        ),
      );
      _betterPlayerController.addEventsListener((event) {
        if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
          Duration? position =
              _betterPlayerController.videoPlayerController?.value.position;
          if (position != null &&
              position.inSeconds >= 10 &&
              !_viewIncremented) {
            _incrementView();
          }
        }
      });
    } else {
      _betterPlayerController =
          BetterPlayerController(BetterPlayerConfiguration());
    }

    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _incrementView() async {
    try {
      await ApiService.incrementView(widget.movie.movieId); // Gọi API
      setState(() {
        _viewIncremented = true; // Đảm bảo chỉ tăng view 1 lần
      });

      // Hiển thị Snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lượt xem đã được tăng!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error incrementing view: $e');

      // Hiển thị Snackbar khi lỗi xảy ra
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tăng lượt xem. Vui lòng thử lại.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  String _generateDefaultResolutionUrl(String baseUrl, String quality) {
    String base = baseUrl.substring(0, baseUrl.lastIndexOf("."));
    String extension = baseUrl.substring(baseUrl.lastIndexOf("."));
    return "$base" + "_$quality$extension";
  }

  Map<String, String> _generateResolutions(String baseUrl) {
    List<String> qualities = ["auto", "1080p", "720p", "480p"];
    String base = baseUrl.substring(0, baseUrl.lastIndexOf("."));
    String extension = baseUrl.substring(baseUrl.lastIndexOf("."));

    return {
      for (var quality in qualities)
        quality: quality == "auto" ? baseUrl : "$base" + "_$quality$extension"
    };
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DownloadProvider()..initializeNotification(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            style: ButtonStyle(
              iconColor: MaterialStateProperty.all(
                  AppDynamicColorBuilder.getGrey800AndGrey300(context)),
            ),
          ),
          title: Text(widget.movie.name,
              style: TextStyle(
                  fontSize: 20,
                  color: AppDynamicColorBuilder.getGrey800AndGrey300(context))),
        ),
        body: Consumer<DownloadProvider>(
          builder: (context, downloadProvider, child) {
            return Column(
              children: [
                Container(
                  height: 200,
                  width: 640,
                  child: BetterPlayer(
                    controller: _betterPlayerController,
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor:
                      AppDynamicColorBuilder.getGrey800AndGrey300(context),
                  unselectedLabelColor:
                      AppDynamicColorBuilder.getGrey800AndGrey300(context),
                  indicatorColor: Colors.orange,
                  tabs: [
                    Tab(text: 'Tập phim'),
                    Tab(text: 'Chi tiết'),
                    Tab(text: 'Bình luận'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEpisodeList(downloadProvider),
                      _buildMovieDetails(),
                      CommentSection(
                          episodeId: _currentEpisodeId ?? 0,
                          movieId: widget.movie.movieId),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEpisodeList(DownloadProvider downloadProvider) {
    // Lọc danh sách các tập có state là true
    final filteredEpisodes =
        widget.movie.episodes.where((episode) => episode.state).toList();

    return ListView.builder(
      itemCount: filteredEpisodes.length,
      itemBuilder: (context, index) {
        final episode = filteredEpisodes[index];
        return ListTile(
          leading: Icon(Icons.play_circle_fill, color: Colors.orange),
          title: Text(
            '${episode.description}',
            style: TextStyle(
                color: AppDynamicColorBuilder.getGrey800AndGrey300(context)),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.download,
                    color:
                        AppDynamicColorBuilder.getGrey800AndGrey300(context)),
                onPressed: () => downloadProvider.downloadEpisode(
                  episode.episodeLink ?? '',
                  '${widget.movie.name}_${episode.description}',
                ),
              ),
            ],
          ),
          onTap: () {
            String selectedVideoUrl = episode.episodeLink ?? '';
            if (selectedVideoUrl.isNotEmpty) {
              setState(() {
                _currentEpisodeId = episode.id;
                _viewIncremented = false;
              });
              final String defaultResolutionUrl =
                  _generateDefaultResolutionUrl(selectedVideoUrl, "480p");
              Map<String, String> resolutions =
                  _generateResolutions(selectedVideoUrl);

              _betterPlayerController.setupDataSource(
                BetterPlayerDataSource(
                  BetterPlayerDataSourceType.network,
                  defaultResolutionUrl,
                  resolutions: resolutions,
                ),
              );
              _betterPlayerController.seekTo(Duration.zero);
            }
          },
        );
      },
    );
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoString = prefs.getString('userInfo');
    if (userInfoString != null) {
      Map<String, dynamic> userInfo = jsonDecode(userInfoString);
      // Trích xuất danh sách các ID phim yêu thích
      List<int> favoriteMovies = (userInfo['loveLists'] ?? [])
          .where((movie) => movie != null && movie['movieId'] != null)
          .map<int>((movie) => movie['movieId'] as int)
          .toList();
      if (favoriteMovies.contains(widget.movie.movieId)) {
        _showSnackBar('Đã xóa khỏi danh sách yêu thích!');
      } else {
        // Gọi API để lưu phim vào danh sách yêu thích
        await ApiService.saveToLoveList(
          username: userInfo['username'],
          movieId: widget.movie.movieId,
        );

        _showSnackBar('Đã thêm vào danh sách yêu thích!');
      }

      // Cập nhật lại `loveLists`
      userInfo['loveLists'] = favoriteMovies
          .map((id) => {'movieId': id}) // Nếu yêu cầu lưu dạng object
          .toList();

      await prefs.setString('userInfo', jsonEncode(userInfo));
      setState(() {}); // Cập nhật UI
    } else {
      _showSnackBar('Bạn cần đăng nhập để sử dụng tính năng này!');
    }
  }

  void _showSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<bool> _isMovieInFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoString = prefs.getString('userInfo');
    if (userInfoString != null) {
      try {
        Map<String, dynamic> userInfo = jsonDecode(userInfoString);

        // Gọi API kiểm tra danh sách yêu thích
        final result = await ApiService.fetchLoveListByMovie(
          username: userInfo['username'].toString(),
          movieId: widget.movie.movieId,
        );
        return result.isNotEmpty;
      } catch (e) {
        print('Error fetching love list: $e');
        return false;
      }
    } else {
      return false;
    }
  }

  Widget _buildMovieDetails() {
    ApiService apiService = ApiService();
    Future<List<Genre>> genreList =
        apiService.fetchGenres(widget.movie.movieId);
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.movie.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppDynamicColorBuilder.getGrey800AndGrey300(context),
                ),
              ),
              FutureBuilder<bool>(
                future: _isMovieInFavorites(),
                builder: (context, snapshot) {
                  bool isFavorite = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: _toggleFavorite,
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.star, color: Colors.orange, size: 20),
              SizedBox(width: 5),
              Text(
                "${widget.movie.rating} / 5.0",
                style: TextStyle(
                    color:
                        AppDynamicColorBuilder.getGrey800AndGrey300(context)),
              ),
              Spacer(),
              Text(
                "Lượt xem: ${widget.movie.view}",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "Mô tả:",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppDynamicColorBuilder.getGrey800AndGrey300(context)),
          ),
          SizedBox(height: 5),
          Text(
            widget.movie.description,
            style: TextStyle(
                color: AppDynamicColorBuilder.getGrey800AndGrey300(context),
                height: 1.5),
          ),
          SizedBox(height: 10),
          if (widget.movie.studio.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hãng phim:",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          AppDynamicColorBuilder.getGrey800AndGrey300(context)),
                ),
                SizedBox(height: 5),
                Text(
                  widget.movie.studio,
                  style: TextStyle(
                      color:
                          AppDynamicColorBuilder.getGrey800AndGrey300(context)),
                ),
              ],
            ),
          SizedBox(height: 10),
          if (widget.movie.country != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Quốc gia:",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          AppDynamicColorBuilder.getGrey800AndGrey300(context)),
                ),
                SizedBox(height: 5),
                Text(
                  widget.movie.country?.name ?? '',
                  style: TextStyle(
                      color:
                          AppDynamicColorBuilder.getGrey800AndGrey300(context)),
                ),
              ],
            ),
          SizedBox(height: 10),
          Text(
            "Thể loại:",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppDynamicColorBuilder.getGrey800AndGrey300(context)),
          ),
          SizedBox(height: 5),
          FutureBuilder<List<Genre>>(
            future: genreList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text(
                  'No genres available',
                  style: TextStyle(
                      color:
                          AppDynamicColorBuilder.getGrey800AndGrey300(context)),
                );
              } else {
                return Wrap(
                  spacing: 20.0,
                  children: snapshot.data!
                      .map((genre) => Text(
                            genre.name,
                            style: TextStyle(
                              fontSize: 16, // Kích thước chữ
                              color:
                                  AppDynamicColorBuilder.getGrey800AndGrey300(
                                      context), // Màu chữ
                            ),
                          ))
                      .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
