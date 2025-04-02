import 'package:flutter/material.dart';
import 'dart:io';
import 'package:better_player_enhanced/better_player.dart';
import 'package:movie_app/global/widgets/project_app_bar.dart';
import 'package:movie_app/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadScreen extends StatefulWidget {
  static final GlobalKey<_DownloadScreenState> globalKey = GlobalKey();
  DownloadScreen({Key? key}) : super(key: globalKey);
  static _DownloadScreenState? of(BuildContext context) {
    return globalKey.currentState;
  }

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late Directory downloadDir;
  late List<Map<String, Object>> videoFiles;
  bool isLoading = false; // Thêm biến trạng thái isLoading

  @override
  void initState() {
    super.initState();
    requestVideoPermission();
    videoFiles = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (videoFiles.isEmpty) {
      _loadDownloadedVideos();
    }
  }

  void reloadDownloads() {
    _loadDownloadedVideos();
  }

  Future<void> _loadDownloadedVideos() async {
    setState(() {
      isLoading = true;
    });
    final minimumLoadingTime = Future.delayed(Duration(milliseconds: 500));
    final downloadDir = Directory(
        "/storage/emulated/0/Android/data/com.example.movie_app/files/Download");

    if (await downloadDir.exists()) {
      final files = downloadDir.listSync();
      final mp4Files = files.where((file) {
        return file is File && file.path.toLowerCase().endsWith(".mp4");
      }).map((file) {
        final stat = (file as File).statSync();
        return {
          'path': file.path,
          'size':
              (stat.size / (1024 * 1024)).toStringAsFixed(2), // Kích thước MB
          'created': stat.modified, // Thời gian sửa đổi cuối cùng
        };
      }).toList();

      await Future.wait([minimumLoadingTime]);
      setState(() {
        videoFiles = mp4Files;
        isLoading = false;
      });
    } else {
      setState(() {
        videoFiles = [];
        isLoading = false;
      });
    }
  }

  Future<void> requestVideoPermission() async {
    var status = await Permission.videos.request();
    if (status.isGranted) {
      print("Video permission granted.");
    } else {
      print("Video permission denied.");
    }
  }

  void _playVideo(String videoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(videoPath: videoPath),
      ),
    );
  }

  void _deleteVideo(String videoPath) async {
    File file = File(videoPath);
    if (await file.exists()) {
      await file.delete();
      await _loadDownloadedVideos(); // Cập nhật lại danh sách video
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ProjectAppBar(
          appBarTitle: 'Danh sách tải xuống',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh,
                color: AppDynamicColorBuilder.getGrey700AndGrey300(context)),
            onPressed: _loadDownloadedVideos,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              )
            : videoFiles.isEmpty
                ? Center(
                    child: Text(
                      "Không có video nào đã tải xuống.",
                      style: TextStyle(
                          color: AppDynamicColorBuilder.getGrey800AndGrey300(
                              context)),
                    ),
                  )
                : ListView.builder(
                    itemCount: videoFiles.length,
                    itemBuilder: (context, index) {
                      final video = videoFiles[index];
                      String fileName =
                          video['path'].toString().split('/').last;
                      String size = video['size'].toString();
                      String created = video['created']
                          .toString()
                          .split('.')[0]; // Định dạng ngày

                      return ListTile(
                        leading:
                            Icon(Icons.video_library, color: Colors.orange),
                        title: Text(
                          fileName,
                          style: TextStyle(
                              color:
                                  AppDynamicColorBuilder.getGrey800AndGrey300(
                                      context)),
                        ),
                        subtitle: Text(
                          "Kích thước: ${size}MB\nNgày tạo: $created",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.play_arrow,
                                  color:
                                      const Color.fromARGB(255, 42, 48, 120)),
                              onPressed: () =>
                                  _playVideo(video['path'].toString()),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteVideo(video['path'].toString()),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatelessWidget {
  final String videoPath;

  const VideoPlayerScreen({required this.videoPath});

  @override
  Widget build(BuildContext context) {
    BetterPlayerController _betterPlayerController =
        BetterPlayerController(BetterPlayerConfiguration());

    _betterPlayerController.setupDataSource(
      BetterPlayerDataSource(
        BetterPlayerDataSourceType.file,
        videoPath,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Phát video"),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: Colors.black,
      ),
      body: BetterPlayer(controller: _betterPlayerController),
      backgroundColor: Colors.black,
    );
  }
}
