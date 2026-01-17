import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings =
    InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    bool critical = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'waste_alerts',
      'Waste Alerts',
      channelDescription: 'Notifications for waste level alerts',
      importance: critical
          ? Importance.max
          : Importance.high,
      priority:
      critical ? Priority.max : Priority.high,
    );

    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }
}
