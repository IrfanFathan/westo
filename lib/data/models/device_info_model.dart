class DeviceInfoModel {
  final String deviceName;
  final String firmwareVersion;
  final String macAddress;
  final String ipAddress;
  final String mode;

  DeviceInfoModel({
    required this.deviceName,
    required this.firmwareVersion,
    required this.macAddress,
    required this.ipAddress,
    required this.mode,
  });

  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) {
    return DeviceInfoModel(
      deviceName: json['deviceName'],
      firmwareVersion: json['firmwareVersion'],
      macAddress: json['macAddress'],
      ipAddress: json['ipAddress'],
      mode: json['mode'],
    );
  }
}
