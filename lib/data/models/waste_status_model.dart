import 'package:westo/domain/entities/waste_status.dart';

/// Data model representing waste status received from ESP32
///
/// This model is responsible for:
/// - Parsing JSON from API / MQTT
/// - Converting data into a domain entity
class WasteStatusModel {
  final int wasteLevel;
  final bool isConnected;
  final bool isCompressorActive;

  WasteStatusModel({
    required this.wasteLevel,
    required this.isConnected,
    required this.isCompressorActive,
  });

  /// Factory constructor to create model from JSON (ESP32 response)
  factory WasteStatusModel.fromJson(Map<String, dynamic> json) {
    return WasteStatusModel(
      wasteLevel: json['wasteLevel'] as int,
      isConnected: json['isConnected'] as bool,
      isCompressorActive: json['isCompressorActive'] as bool,
    );
  }

  /// Convert model into domain entity
  ///
  /// Domain layer must never depend on data models,
  /// so conversion happens here.
  WasteStatus toEntity() {
    return WasteStatus(
      wasteLevel: wasteLevel,
      isConnected: isConnected,
      isCompressorActive: isCompressorActive,
    );
  }
}
