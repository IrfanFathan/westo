import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings =
    InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
  }

  static Future<void> show({
    required int id,
    required String title,
    required String body,
    bool critical = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'waste_alerts',
      'Waste Alerts',
      channelDescription: 'Waste bin level alerts',
      importance:
      critical ? Importance.max : Importance.high,
      priority:
      critical ? Priority.max : Priority.high,
    );

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }
}
