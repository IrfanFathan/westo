import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:westo/domain/entities/waste_status.dart';
import 'package:westo/domain/usecases/get_waste_level.dart';
import 'package:westo/domain/usecases/set_trigger_state.dart';
import 'package:westo/data/repositories/waste_repository_impl.dart';

/// ViewModel responsible for managing waste-bin state for the UI
///
/// Responsibilities:
/// - Load waste status using HTTP (REST)
/// - Decide ESP32 connection ONLY via HTTP
/// - Toggle trigger system (fires HTTP only when enabling)
/// - Apply 30-second cool-down with visible countdown
///
/// IMPORTANT:
/// - MQTT is NOT used (ESP32 firmware does not support it yet)
/// - REST is the single source of truth
class WasteViewModel extends ChangeNotifier {
  final GetWasteLevel getWasteLevel;
  final SetTriggerState setTriggerState;
  final WasteRepositoryImpl repository; // kept to avoid breaking DI

  WasteViewModel({
    required this.getWasteLevel,
    required this.setTriggerState,
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

  // -------------------------------------------------------
  // Cooldown state — 30-second timer after a successful trigger
  // -------------------------------------------------------

  /// Whether the trigger is currently in cooldown
  bool _isInCooldown = false;
  bool get isInCooldown => _isInCooldown;

  /// Remaining seconds in the cooldown (0 = not in cooldown)
  int _cooldownRemaining = 0;
  int get cooldownRemaining => _cooldownRemaining;

  /// Periodic timer that ticks every 1 second during cooldown
  Timer? _cooldownTimer;

  /// Cooldown duration in seconds
  static const int _cooldownSeconds = 30;

  /// Trigger system state (enabled/disabled)
  bool _isTriggerEnabled = false;
  bool get isTriggerEnabled => _isTriggerEnabled;

  /// Whether trigger toggle is in progress
  bool _isTriggerLoading = false;
  bool get isTriggerLoading => _isTriggerLoading;

  /// Timer for regular updates
  Timer? _pollingTimer;

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _cooldownTimer?.cancel(); // Clean up cooldown timer
    super.dispose();
  }

  /// -------------------------------
  /// Load initial data using HTTP
  /// -------------------------------
  ///
  /// Rules:
  /// - HTTP success → ESP32 Connected
  /// - HTTP failure → ESP32 Disconnected
  Future<void> loadInitialStatus() async {
    if (_wasteStatus == null) {
      _setLoading(true);
    }

    try {
      _wasteStatus = await getWasteLevel();

      _isEsp32Connected = true;
      _errorMessage = null;
    } catch (e) {
      _isEsp32Connected = false;
      _errorMessage = 'ESP32 not reachable';
    }

    if (_isLoading) {
      _setLoading(false);
    } else {
      notifyListeners();
    }
  }

  /// Start polling for real-time updates
  void startPolling() {
    loadInitialStatus(); // Load immediately first
    
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!_isLoading && !_isInCooldown) {
        try {
          _wasteStatus = await getWasteLevel();
          _isEsp32Connected = true;
          _errorMessage = null;
          notifyListeners();
        } catch (e) {
          if (_isEsp32Connected) {
            _isEsp32Connected = false;
            _errorMessage = 'ESP32 connection lost';
            notifyListeners();
          }
        }
      }
    });
  }

  /// Stop polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// -------------------------------------------------------
  /// Unified trigger toggle (merged endpoint)
  /// -------------------------------------------------------
  ///
  /// Behavior:
  /// - enable = true  → sends POST /compress {"trigger": 1}
  ///                     then starts 30-second cooldown
  /// - enable = false → local-only state change, NO HTTP call
  ///
  /// During cooldown the button is disabled and shows remaining time.
  /// Returns true if the operation succeeded.
  Future<bool> toggleTrigger(bool enable) async {
    if (_isTriggerLoading || _isInCooldown) return false;

    // ----- Disable: local-only, no HTTP -----
    if (!enable) {
      _isTriggerEnabled = false;
      notifyListeners();
      return true;
    }

    // ----- Enable: send HTTP then start cooldown -----
    try {
      _isTriggerLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Merged endpoint call — sends {"trigger": 1} to POST /compress
      await setTriggerState(true);

      // Mark trigger as enabled
      _isTriggerEnabled = true;
      _isTriggerLoading = false;
      notifyListeners();

      // Reload waste status after triggering
      try {
        _wasteStatus = await getWasteLevel();
        notifyListeners();
      } catch (_) {
        // Non-critical — status will refresh on next poll
      }

      // Start 30-second cooldown with visible countdown
      _startCooldown();

      return true;
    } catch (e) {
      _isTriggerLoading = false;
      _errorMessage = 'Failed to enable trigger';
      notifyListeners();
      return false;
    }
  }

  /// -------------------------------------------------------
  /// Cooldown timer — ticks every 1 second for 30 seconds
  /// -------------------------------------------------------
  ///
  /// Sets _isInCooldown = true and _cooldownRemaining = 30,
  /// then decrements every second. At 0, re-enables the button.
  void _startCooldown() {
    _cooldownTimer?.cancel();
    _isInCooldown = true;
    _cooldownRemaining = _cooldownSeconds;
    notifyListeners();

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _cooldownRemaining--;

      if (_cooldownRemaining <= 0) {
        // Cooldown complete — re-enable the trigger button
        timer.cancel();
        _cooldownTimer = null;
        _isInCooldown = false;
        _cooldownRemaining = 0;
      }

      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
