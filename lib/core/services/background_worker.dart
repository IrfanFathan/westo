import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

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

          final int wasteLevel = data['wasteLevel'];

          if (wasteLevel >= 100) {
            await NotificationService.show(
              id: 100,
              title: '🚨 Bin Fully Loaded',
              body:
              'Waste bin is 100% full. Immediate action required.',
              critical: true,
            );
          } else if (wasteLevel >= 90) {
            await NotificationService.show(
              id: 90,
              title: '⚠ Waste Almost Full',
              body:
              'Waste level reached 90%. Compression required.',
            );
          }
        }
      } catch (_) {
        // ESP32 unreachable → silently ignore
      }
    }
    return Future.value(true);
  });
}
