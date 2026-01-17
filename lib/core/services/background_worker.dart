import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;

import 'notification_service.dart';

const String wasteCheckTask = 'wasteCheckTask';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == wasteCheckTask) {
      try {
        final response = await http
            .get(Uri.parse('http://192.168.4.1/status'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data =
          json.decode(response.body) as Map<String, dynamic>;

          final int level = data['wasteLevel'];

          if (level >= 100) {
            await NotificationService.showNotification(
              id: 2,
              title: '🚨 Bin Fully Loaded',
              body:
              'Waste bin is 100% full. Immediate action required.',
              critical: true,
            );
          } else if (level >= 90) {
            await NotificationService.showNotification(
              id: 1,
              title: '⚠ Waste Almost Full',
              body:
              'Waste level reached 90%. Compression should be triggered.',
            );
          }
        }
      } catch (_) {
        // Silent fail (ESP32 may be off)
      }
    }
    return Future.value(true);
  });
}
