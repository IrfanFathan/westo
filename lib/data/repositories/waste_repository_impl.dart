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
/// UI and domain NEVER talk directly to services.
class WasteRepositoryImpl implements WasteRepository {
  final ApiService apiService;
  final MqttService mqttService;

  WasteRepositoryImpl({
    required this.apiService,
    required this.mqttService,
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
  /// This is NOT part of the domain interface,
  /// but exposed for ViewModels to consume.
  Stream<WasteStatus> watchWasteStatus() {
    return mqttService.wasteStatusStream.map(
          (WasteStatusModel model) => model.toEntity(),
    );
  }

  /// Fetch ESP32 device information (HTTP)
  ///
  /// This method is intentionally NOT added to the domain interface
  /// because device metadata is a presentation concern,
  /// not core business logic.
  Future<DeviceInfoModel> getDeviceInfo() async {
    return apiService.fetchDeviceInfo();
  }
}
