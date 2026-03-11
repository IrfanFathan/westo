import 'package:westo/domain/entities/waste_status.dart';

/// Repository interface for waste-bin related operations
///
/// This defines WHAT the system can do,
/// not HOW it is done.
abstract class WasteRepository {
  /// Fetch the current status of the waste bin
  ///
  /// Returns a [WasteStatus] entity that represents
  /// the real-world state of the bin.
  Future<WasteStatus> getWasteStatus();

  /// Sends a trigger signal to the ESP32
  ///
  /// [enable] = true sends {"trigger": 1}
  /// [enable] = false sends {"trigger": 0}
  Future<void> sendTriggerSignal(bool enable);
}