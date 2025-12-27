class WasteStatus {
  /// Waste fill level in percentage (0–100)
  final int wasteLevel;

  /// Indicates whether the device is connected
  final bool isConnected;

  /// Indicates whether the compressor is currently running
  final bool isCompressorActive;

  /// Creates an immutable WasteStatus object
  const WasteStatus({
    required this.wasteLevel,
    required this.isConnected,
    required this.isCompressorActive,
  });

  /// Returns true when the bin is almost full
  bool get isFull => wasteLevel >= 90;

  /// Returns true when the bin is nearly empty
  bool get isEmpty => wasteLevel <= 5;

  /// Returns true when waste level is in normal range
  bool get isNormal => wasteLevel > 5 && wasteLevel < 90;
}
