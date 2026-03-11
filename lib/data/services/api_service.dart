import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:westo/data/models/waste_status_model.dart';
import 'package:westo/data/models/device_info_model.dart';

/// API service responsible for communicating with ESP32 via HTTP
///
/// This class:
/// - Calls ESP32 REST endpoints
/// - Parses JSON responses
/// - Returns DATA MODELS (not entities)
class ApiService {
  /// Base URL of ESP32 (AP mode default IP)
  ///
  /// Later, this can be moved to a config file
  static const String _baseUrl = 'http://192.168.4.1';

  /// Fetch current waste status from ESP32
  ///
  /// Endpoint: GET /status
  Future<WasteStatusModel> fetchWasteStatus() async {
    final uri = Uri.parse('$_baseUrl/status');

    final response = await http.get(uri).timeout(
      const Duration(seconds: 5),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap =
      json.decode(response.body) as Map<String, dynamic>;

      return WasteStatusModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to fetch waste status (HTTP ${response.statusCode})',
      );
    }
  }

  /// Send trigger signal to ESP32
  ///
  /// Endpoint: POST /compress
  /// Body: {"trigger": 1} (enable) or {"trigger": 0} (disable)
  ///
  /// Uses the existing /compress endpoint which is supported by ESP32 firmware.
  /// Includes retry logic: up to 2 retries with 3s timeout per attempt.
  Future<void> sendTriggerSignal(bool enable) async {
    final uri = Uri.parse('$_baseUrl/compress');
    final body = json.encode({'trigger': enable ? 1 : 0});
    const maxRetries = 2;

    Exception? lastError;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: body,
            )
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          return; // Success
        } else {
          lastError = Exception(
            'Trigger failed (HTTP ${response.statusCode})',
          );
        }
      } on SocketException catch (e) {
        lastError = Exception('ESP32 unreachable: $e');
      } catch (e) {
        lastError = Exception('Trigger request failed: $e');
      }

      // Wait briefly before retry (except on last attempt)
      if (attempt < maxRetries) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    throw lastError ?? Exception('Trigger failed after retries');
  }

  /// Fetch ESP32 device information
  ///
  /// Endpoint: GET /device/info
  Future<DeviceInfoModel> fetchDeviceInfo() async {
    final uri = Uri.parse('$_baseUrl/device/info');

    final response = await http.get(uri).timeout(
      const Duration(seconds: 5),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap =
      json.decode(response.body) as Map<String, dynamic>;

      return DeviceInfoModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to fetch device info (HTTP ${response.statusCode})',
      );
    }
  }
}
