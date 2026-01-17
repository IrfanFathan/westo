import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:westo/domain/entities/waste_status.dart';
import 'package:westo/domain/usecases/get_waste_level.dart';
import 'package:westo/domain/usecases/trigger_compressor.dart';
import 'package:westo/data/repositories/waste_repository_impl.dart';

/// ViewModel responsible for managing waste-bin state for the UI
///
/// Responsibilities:
/// - Load waste status using HTTP (REST)
/// - Decide ESP32 connection ONLY via HTTP
/// - Trigger compressor safely
/// - Apply cool-down to avoid repeated triggers
///
/// IMPORTANT:
/// - MQTT is NOT used (ESP32 firmware does not support it yet)
/// - REST is the single source of truth
class WasteViewModel extends ChangeNotifier {
  final GetWasteLevel getWasteLevel;
  final TriggerCompressor triggerCompressor;
  final WasteRepositoryImpl repository; // kept to avoid breaking DI

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

  /// ESP32 connection status (decided ONLY by HTTP)
  bool _isEsp32Connected = false;
  bool get isEsp32Connected => _isEsp32Connected;

  /// Error message (if any)
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Cool-down to avoid repeated compressor triggers
  bool _isInCooldown = false;
  bool get isInCooldown => _isInCooldown;

  /// Cool-down duration
  static const Duration _cooldownDuration = Duration(seconds: 15);

  /// -------------------------------
  /// Load initial data using HTTP
  /// -------------------------------
  ///
  /// Rules:
  /// - HTTP success → ESP32 Connected
  /// - HTTP failure → ESP32 Disconnected
  Future<void> loadInitialStatus() async {
    _setLoading(true);

    try {
      _wasteStatus = await getWasteLevel();

      _isEsp32Connected = true;
      _errorMessage = null;
    } catch (e) {
      _isEsp32Connected = false;
      _errorMessage = 'ESP32 not reachable';
    }

    _setLoading(false);
  }

  /// -------------------------------
  /// Trigger compressor safely
  /// -------------------------------
  ///
  /// Features:
  /// - Prevents repeated triggers (cool-down)
  /// - Refreshes waste status after compression
  Future<void> compressWaste() async {
    if (_isInCooldown) return;

    try {
      _isInCooldown = true;
      notifyListeners();

      // Send command to ESP32
      await triggerCompressor();

      // Reload updated status after compression
      _wasteStatus = await getWasteLevel();

      notifyListeners();

      // Reset cool-down after delay
      Future.delayed(_cooldownDuration, () {
        _isInCooldown = false;
        notifyListeners();
      });
    } catch (e) {
      _isInCooldown = false;
      _errorMessage = 'Failed to trigger compressor';
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
