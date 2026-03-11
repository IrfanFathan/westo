import 'package:westo/domain/repositories/waste_repository.dart';

/// Use case for enabling or disabling the trigger system
///
/// Sends {"trigger": 1} (enable) or {"trigger": 0} (disable) to ESP32
class SetTriggerState {
  final WasteRepository repository;

  /// Constructor receives repository dependency
  SetTriggerState(this.repository);

  /// Executes the trigger state change
  ///
  /// [enable] = true → send 1 to ESP32
  /// [enable] = false → send 0 to ESP32
  Future<void> call(bool enable) async {
    await repository.sendTriggerSignal(enable);
  }
}
