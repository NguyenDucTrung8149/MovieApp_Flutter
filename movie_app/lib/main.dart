import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_app/Api/NavigationService.dart';
import 'package:movie_app/NotificationService.dart';
import 'package:movie_app/base/base_screen.dart';
import 'package:movie_app/firebase_options.dart';
import 'package:movie_app/provider/FilterProvider.dart';
import 'package:movie_app/provider/SearchProvider.dart';
import 'package:movie_app/provider/download_provider.dart';
import 'package:movie_app/theme/app_theme.dart';
import 'package:movie_app/theme_notifier.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

Future<void> requestNotificationPermission() async {
  var status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  requestNotificationPermission();
  final notificationService = NotificationService();
  await notificationService.initialize();
  await FirebaseMessaging.instance.setAutoInitEnabled(false);
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.instance.subscribeToTopic("new_episode");
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notificationService = NotificationService();
    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // Ưu tiên lấy thông tin từ `data` payload
    final title = message.data['title'] ?? 'Thông báo';
    final body = message.data['body'] ?? '';
    final movieId = message.data['movieId'];
    print("Message received: ${message.data}");
    notificationService.showNotification(
      id: notificationId,
      title: title,
      body: body,
      payload: movieId,
    );
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
        ChangeNotifierProvider(create: (_) => DownloadProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Khởi tạo Firebase
  final notificationService = NotificationService();
  await notificationService.initialize();

  final title = message.data['title'] ?? 'Thông báo';
  final body = message.data['body'] ?? '';
  final movieId = message.data['movieId'];
  int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  notificationService.showNotification(
    id: notificationId,
    title: title,
    body: body,
    payload: movieId,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      designSize: const Size(428, 926),
      builder: (context, child) => ChangeNotifierProvider(
        create: (context) => ThemeNotifier(),
        child: Consumer<ThemeNotifier>(
          builder: (context, ThemeNotifier themeNotifier, child) => MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            debugShowCheckedModeBanner: false,
            theme:
                themeNotifier.isDark ? AppTheme.darkMode : AppTheme.lightMode,
            home: const BaseScreen(),
          ),
        ),
      ),
    );
  }
}
