import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:westo/core/utils/platform.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  /// Initialize notification service
  /// Only works on Android platform
  static Future<void> init() async {
    // Skip initialization on web or non-Android platforms
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings =
    InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
  }

  /// Show a notification
  /// Only works on Android platform
  static Future<void> show({
    required int id,
    required String title,
    required String body,
    bool critical = false,
  }) async {
    // Skip on web or non-Android platforms
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

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
