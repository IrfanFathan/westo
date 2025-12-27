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

  /// Triggers the waste compressor mechanism
  ///
  /// The implementation may call an API, IoT device,
  /// or mock service, but the UI does not care.
  Future<void> triggerCompressor();
}