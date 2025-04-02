import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadProvider with ChangeNotifier {
  final Map<int, bool> isDownloadingMap = {};
  final Map<int, double> progressMap = {};
  final Map<int, bool> isCancelledMap = {};

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Future<void> initializeNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId != null &&
            response.actionId!.startsWith('cancel_')) {
          final id = int.parse(response.actionId!.split('_').last);
          cancelDownload(id);
        }
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'download_channel',
      'Tải xuống tập phim',
      description: 'Hiển thị tiến trình tải xuống',
      importance: Importance.low,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  String generateMp4Url(String hlsUrl) {
    String fileName = Uri.parse(hlsUrl).pathSegments.last;
    String baseName = fileName.replaceAll(".m3u8", "");
    return "https://movieweb.s3.ap-southeast-2.amazonaws.com/$baseName.mp4";
  }

  @override
  void dispose() {
    print('DownloadProvider đã bị dispose');
    super.dispose();
  }

// Hàm kiểm tra mạng
  Future<bool> hasNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

// Hiển thị thông báo lỗi
  void _showErrorNotification(String message) {
    flutterLocalNotificationsPlugin.show(
      1,
      'Lỗi tải xuống',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'download_channel',
          'Lỗi tải xuống',
          channelDescription: 'Mô tả lỗi xảy ra trong quá trình tải',
          importance: Importance.high,
        ),
      ),
    );
  }

  Future<void> downloadEpisode(String hlsUrl, String episodeName) async {
    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (!(await hasNetworkConnection())) {
      _showErrorNotification('Không có kết nối mạng');
      return;
    }

    String mp4Url = generateMp4Url(hlsUrl);
    isCancelledMap[notificationId] = false;

    try {
      isDownloadingMap[notificationId] = true;
      progressMap[notificationId] = 0.0;
      notifyListeners();

      Directory? baseDir = await getExternalStorageDirectory();
      if (baseDir == null) throw Exception('Không thể lấy thư mục gốc.');
      Directory downloadDir = Directory("${baseDir.path}/Download");
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      String savePath = "${downloadDir.path}/$episodeName.mp4";
      var response =
          await http.Client().send(http.Request('GET', Uri.parse(mp4Url)));
      print("Bắt đầu tải tập: $episodeName từ URL: $mp4Url");
      File file = File(savePath);
      var sink = file.openWrite();

      int downloaded = 0;
      int total = response.contentLength ?? 1;

      // Quản lý luồng dữ liệu
      StreamSubscription<List<int>>? subscription;

      subscription = response.stream.listen(
        (data) {
          if (isCancelledMap[notificationId] == true) {
            subscription?.cancel();
            sink.close();
            isDownloadingMap[notificationId] = false;
            progressMap[notificationId] = 0.0;
            notifyListeners();
            flutterLocalNotificationsPlugin.cancel(notificationId);
            return;
          }

          downloaded += data.length;
          sink.add(data);

          // Cập nhật tiến trình
          int progressPercentage = ((downloaded / total) * 100).toInt();
          flutterLocalNotificationsPlugin.show(
            notificationId,
            'Đang tải xuống',
            'Tập phim: $episodeName',
            NotificationDetails(
              android: AndroidNotificationDetails(
                'download_channel',
                'Tải xuống tập phim',
                channelDescription: 'Hiển thị tiến trình tải xuống',
                importance: Importance.low,
                showProgress: true,
                maxProgress: 100,
                progress: progressPercentage,
                onlyAlertOnce: true,
                actions: [
                  AndroidNotificationAction(
                    'cancel_$notificationId',
                    'Hủy',
                    showsUserInterface: true,
                  ),
                ],
              ),
            ),
          );

          progressMap[notificationId] = downloaded / total;
          notifyListeners();
        },
        onDone: () async {
          if (isCancelledMap[notificationId] == true) return;
          await sink.close();
          isDownloadingMap[notificationId] = false;
          progressMap[notificationId] = 0.0;
          notifyListeners();

          flutterLocalNotificationsPlugin.show(
            0,
            'Tải xuống hoàn tất',
            'Tập phim: $episodeName đã được tải về thành công!',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'download_channel',
                'Tải xuống tập phim',
                channelDescription: 'Hoàn tất tải xuống',
                importance: Importance.high,
              ),
            ),
          );
        },
        onError: (error) async {
          await sink.close();
          isDownloadingMap[notificationId] = false;
          progressMap[notificationId] = 0.0;
          notifyListeners();

          flutterLocalNotificationsPlugin.show(
            0,
            'Lỗi tải xuống',
            'Không thể tải tập phim: $episodeName.',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'download_channel',
                'Lỗi tải xuống',
                channelDescription: 'Xảy ra lỗi khi tải xuống tập phim',
                importance: Importance.high,
              ),
            ),
          );
        },
      );
    } catch (e) {
      isDownloadingMap[notificationId] = false;
      progressMap[notificationId] = 0.0;
      notifyListeners();
      _showErrorNotification('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  void cancelDownload(int notificationId) {
    if (isDownloadingMap[notificationId] == true) {
      isCancelledMap[notificationId] = true;
      flutterLocalNotificationsPlugin.cancel(notificationId); // Hủy thông báo
      notifyListeners();
    }
  }
}
