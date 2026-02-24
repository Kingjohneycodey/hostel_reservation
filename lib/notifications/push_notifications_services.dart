import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  static final _local = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Permission
    await FirebaseMessaging.instance.requestPermission();

    // Local notification setup
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _local.initialize(initSettings);

    // Android channel
    const channel = AndroidNotificationChannel(
      'default_channel',
      'General Notifications',
      description: 'General notifications',
      importance: Importance.max,
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Print token
    final token = await FirebaseMessaging.instance.getToken();
    print('🔥 FCM TOKEN: $token');

    // Foreground messages => show popup
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final title = message.notification?.title ?? 'Notification';
      final body = message.notification?.body ?? '';

      await _local.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'General Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    });
  }
}
