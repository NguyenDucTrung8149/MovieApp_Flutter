import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:movie_app/Api/ApiService.dart';
import 'package:movie_app/Api/NavigationService.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Khởi tạo
  Future<void> initialize() async {
    // Tạo kênh thông báo
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // ID của kênh
      'High Importance Notifications', // Tên kênh
      description: 'This channel is used for important notifications.', // Mô tả
      importance: Importance.high,
    );

    // Đăng ký kênh
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Cấu hình khởi tạo
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        // Nhận dữ liệu từ thông báo khi người dùng nhấn vào
        if (notificationResponse.payload != null) {
          final String payload = notificationResponse.payload!;
          final int movieId = int.parse(payload);
          final movie = await ApiService.fetchMovieDetails(movieId);
          print("Payload: ${movie?.name}");
          if (movie != null) {
            // Chuyển hướng đến MovieDetailScreen
            NavigationService.navigateToMovieDetail(movie);
          } else {
            print("Không tìm thấy phim với ID: $movieId");
          }
        }
      },
    );
  }

  // Hiển thị thông báo
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'high_importance_channel', // ID của kênh
      'High Importance Notifications', // Tên của kênh
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
