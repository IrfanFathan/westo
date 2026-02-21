import 'package:flutter/material.dart';
import 'package:westo/data/models/device_info_model.dart';
import 'package:westo/data/repositories/waste_repository_impl.dart';

/// DeviceViewModel
///
/// Responsible for:
/// - Fetching ESP32 device information
/// - Managing loading & error state
/// - Exposing data to the UI
class DeviceViewModel extends ChangeNotifier {
  final WasteRepositoryImpl repository;

  DeviceViewModel({required this.repository});

  DeviceInfoModel? deviceInfo;
  bool isLoading = false;
  String? errorMessage;

  /// Load device information from ESP32
  Future<void> loadDeviceInfo() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      deviceInfo = await repository.getDeviceInfo();
    } catch (e) {
      errorMessage = 'Failed to load device information';
    }

    isLoading = false;
    notifyListeners();
  }
}
