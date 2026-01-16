import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:westo/domain/entities/waste_status.dart';
import 'package:westo/domain/usecases/get_waste_level.dart';
import 'package:westo/domain/usecases/trigger_compressor.dart';
import 'package:westo/data/repositories/waste_repository_impl.dart';

/// ViewModel responsible for managing waste-bin state for the UI
///
/// Responsibilities:
/// - Load waste status using HTTP
/// - Listen to real-time MQTT updates
/// - Track ESP32 connection state
/// - Expose clean state to UI
class WasteViewModel extends ChangeNotifier {
  final GetWasteLevel getWasteLevel;
  final TriggerCompressor triggerCompressor;
  final WasteRepositoryImpl repository;

  WasteViewModel({
    required this.getWasteLevel,
    required this.triggerCompressor,
    required this.repository,
  });

  /// Current waste status
  WasteStatus? _wasteStatus;
  WasteStatus? get wasteStatus => _wasteStatus;

  /// Loading indicator
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// ESP32 connection status (SOURCE OF TRUTH)
  bool _isEsp32Connected = false;
  bool get isEsp32Connected => _isEsp32Connected;

  /// Error message (if any)
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<WasteStatus>? _mqttSubscription;

  /// -------------------------------
  /// Load initial data using HTTP
  /// -------------------------------
  ///
  /// Connection logic:
  /// - HTTP success  → ESP32 Connected
  /// - HTTP failure  → ESP32 Disconnected
  Future<void> loadInitialStatus() async {
    _setLoading(true);

    try {
      _wasteStatus = await getWasteLevel();

      _isEsp32Connected = true; // ✅ API success
      _errorMessage = null;
    } catch (e) {
      _isEsp32Connected = false; // ❌ API failed
      _errorMessage = 'ESP32 not reachable';
    }

    _setLoading(false);
  }

  /// -------------------------------
  /// Start real-time MQTT updates
  /// -------------------------------
  ///
  /// MQTT data implies ESP32 is connected
  void startRealtimeUpdates() {
    _mqttSubscription = repository.watchWasteStatus().listen(
          (WasteStatus status) {
        _wasteStatus = status;
        _isEsp32Connected = true; // ✅ MQTT alive
        notifyListeners();
      },
      onError: (_) {
        _isEsp32Connected = false; // ❌ MQTT error
        notifyListeners();
      },
    );
  }

  /// -------------------------------
  /// Trigger compressor
  /// -------------------------------
  Future<void> compressWaste() async {
    try {
      await triggerCompressor();
    } catch (e) {
      _errorMessage = 'Failed to trigger compressor';
      notifyListeners();
    }
  }

  /// -------------------------------
  /// Cleanup MQTT subscription
  /// -------------------------------
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
