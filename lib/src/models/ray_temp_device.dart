import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Represents a discovered Ray Temp Blue device.
class RayTempDevice {
  /// The Bluetooth device.
  final BluetoothDevice device;
  
  /// The device name (e.g., "12345678 RayTempBlue").
  final String name;
  
  /// The device serial number extracted from the name.
  final String serialNumber;
  
  /// The RSSI (signal strength) when discovered.
  final int rssi;
  
  /// The device MAC address.
  String get address => device.remoteId.str;
  
  /// Whether the device is currently connected.
  bool get isConnected => device.isConnected;

  /// Creates a new Ray Temp device representation.
  const RayTempDevice({
    required this.device,
    required this.name,
    required this.serialNumber,
    required this.rssi,
  });

  /// Creates a RayTempDevice from a scan result.
  factory RayTempDevice.fromScanResult(ScanResult scanResult) {
    final deviceName = scanResult.device.platformName;
    final serialNumber = _extractSerialNumber(deviceName);
    
    return RayTempDevice(
      device: scanResult.device,
      name: deviceName,
      serialNumber: serialNumber,
      rssi: scanResult.rssi,
    );
  }

  /// Extracts the serial number from the device name.
  /// Device names follow the pattern: "12345678 RayTempBlue"
  static String extractSerialNumber(String deviceName) {
    final parts = deviceName.split(' ');
    if (parts.isNotEmpty && parts[0].length == 8) {
      return parts[0];
    }
    return 'Unknown';
  }

  /// Private alias for backward compatibility
  static String _extractSerialNumber(String deviceName) => extractSerialNumber(deviceName);

  /// Checks if this device is a Ray Temp Blue device based on its name.
  static bool isRayTempBlue(String deviceName) {
    return deviceName.toLowerCase().contains('raytempblue') ||
           deviceName.toLowerCase().contains('raytemp blue');
  }

  @override
  String toString() {
    return 'RayTempDevice(name: $name, serialNumber: $serialNumber, '
           'address: $address, rssi: ${rssi}dBm)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RayTempDevice &&
        other.device.remoteId == device.remoteId;
  }

  @override
  int get hashCode => device.remoteId.hashCode;
}
