import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:westo/domain/entities/waste_status.dart';
import 'package:westo/domain/usecases/get_waste_level.dart';
import 'package:westo/domain/usecases/trigger_compressor.dart';
import 'package:westo/data/repositories/waste_repository_impl.dart';

/// ViewModel responsible for managing waste-bin state for the UI
///
/// This class:
/// - Holds UI state
/// - Calls domain use cases
/// - Listens to real-time MQTT updates
/// - Notifies UI when data changes
class WasteViewModel extends ChangeNotifier {
  final GetWasteLevel getWasteLevel;
  final TriggerCompressor triggerCompressor;
  final WasteRepositoryImpl repository;

  WasteViewModel({
    required this.getWasteLevel,
    required this.triggerCompressor,
    required this.repository,
  });

  /// Current waste status shown in UI
  WasteStatus? _wasteStatus;
  WasteStatus? get wasteStatus => _wasteStatus;

  /// Loading indicator for UI
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Error message (if any)
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<WasteStatus>? _mqttSubscription;

  /// Load initial data using HTTP (REST)
  Future<void> loadInitialStatus() async {
    _setLoading(true);

    try {
      _wasteStatus = await getWasteLevel();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load device status';
    }

    _setLoading(false);
  }

  /// Start listening to real-time MQTT updates
  void startRealtimeUpdates() {
    _mqttSubscription = repository
        .watchWasteStatus()
        .listen((WasteStatus status) {
      _wasteStatus = status;
      notifyListeners();
    });
  }

  /// Trigger compressor action from UI
  Future<void> compressWaste() async {
    try {
      await triggerCompressor();
    } catch (e) {
      _errorMessage = 'Failed to trigger compressor';
      notifyListeners();
    }
  }

  /// Stop MQTT listening (important to avoid memory leaks)
  void disposeRealtimeUpdates() {
    _mqttSubscription?.cancel();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    disposeRealtimeUpdates();
    super.dispose();
  }
}
