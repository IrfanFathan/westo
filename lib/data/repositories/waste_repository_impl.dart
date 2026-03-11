import 'package:westo/domain/entities/waste_status.dart';
import 'package:westo/domain/repositories/waste_repository.dart';

import 'package:westo/data/models/waste_status_model.dart';
import 'package:westo/data/models/device_info_model.dart';
import 'package:westo/data/services/api_service.dart';
import 'package:westo/data/services/mqtt_service.dart';

/// Concrete implementation of [WasteRepository]
///
/// This class connects:
/// - DATA layer (API / MQTT)
/// - DOMAIN layer (Entities & UseCases)
///
/// Notes:
/// - REST (HTTP) is the CURRENT source of truth
/// - MQTT is OPTIONAL and reserved for future real-time updates
class WasteRepositoryImpl implements WasteRepository {
  final ApiService apiService;

  /// MQTT is optional for now
  final MqttService? mqttService;

  WasteRepositoryImpl({
    required this.apiService,
    this.mqttService, // ✅ optional
  });

  /// Fetch waste status using HTTP (REST)
  ///
  /// Used for:
  /// - Initial data load
  /// - Manual refresh
  @override
  Future<WasteStatus> getWasteStatus() async {
    final WasteStatusModel model =
    await apiService.fetchWasteStatus();

    // Convert DATA model → DOMAIN entity
    return model.toEntity();
  }

  /// Trigger compressor using HTTP command
  @override
  Future<void> triggerCompressor() async {
    await apiService.triggerCompressor();
  }

  /// Stream real-time waste status updates using MQTT
  ///
  /// ⚠️ Currently NOT USED
  /// ⚠️ ESP32 firmware does not publish MQTT data yet
  Stream<WasteStatus> watchWasteStatus() {
    if (mqttService == null) {
      // Safe fallback when MQTT is disabled
      return const Stream.empty();
    }

    return mqttService!.wasteStatusStream.map(
          (WasteStatusModel model) => model.toEntity(),
    );
  }

  /// Fetch ESP32 device information (HTTP)
  ///
  /// Device metadata is a presentation concern,
  /// not core business logic — so it stays out of domain.
  Future<DeviceInfoModel> getDeviceInfo() async {
    return apiService.fetchDeviceInfo();
  }
}
