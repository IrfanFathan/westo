import 'dart:convert';
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

  /// Trigger the compressor on ESP32
  ///
  /// Endpoint: POST /compress
  Future<void> triggerCompressor() async {
    final uri = Uri.parse('$_baseUrl/compress');

    final response = await http.post(uri).timeout(
      const Duration(seconds: 5),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to trigger compressor (HTTP ${response.statusCode})',
      );
    }
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
