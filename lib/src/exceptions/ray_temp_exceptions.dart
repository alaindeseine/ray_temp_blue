/// Base exception for all Ray Temp Blue related errors.
abstract class RayTempException implements Exception {
  /// The error message.
  final String message;
  
  /// Optional underlying cause.
  final dynamic cause;

  const RayTempException(this.message, [this.cause]);

  @override
  String toString() => 'RayTempException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Exception thrown when there are Bluetooth permission issues.
class RayTempPermissionException extends RayTempException {
  /// The missing permissions.
  final List<String> missingPermissions;

  const RayTempPermissionException(
    super.message,
    this.missingPermissions, [
    super.cause,
  ]);

  @override
  String toString() => 'RayTempPermissionException: $message. Missing permissions: ${missingPermissions.join(', ')}';
}

/// Exception thrown when Bluetooth is not available or disabled.
class RayTempBluetoothException extends RayTempException {
  const RayTempBluetoothException(super.message, [super.cause]);

  @override
  String toString() => 'RayTempBluetoothException: $message';
}

/// Exception thrown when device connection fails.
class RayTempConnectionException extends RayTempException {
  /// The device that failed to connect.
  final String? deviceAddress;

  const RayTempConnectionException(
    super.message, [
    this.deviceAddress,
    super.cause,
  ]);

  @override
  String toString() => 'RayTempConnectionException: $message${deviceAddress != null ? ' (Device: $deviceAddress)' : ''}';
}

/// Exception thrown when the sensor reports an error.
class RayTempSensorException extends RayTempException {
  /// The error code from the sensor (e.g., 0xFFFFFFFF).
  final int? errorCode;

  const RayTempSensorException(
    super.message, [
    this.errorCode,
    super.cause,
  ]);

  @override
  String toString() => 'RayTempSensorException: $message${errorCode != null ? ' (Error code: 0x${errorCode!.toRadixString(16).toUpperCase()})' : ''}';
}

/// Exception thrown when device scanning fails.
class RayTempScanException extends RayTempException {
  const RayTempScanException(super.message, [super.cause]);

  @override
  String toString() => 'RayTempScanException: $message';
}

/// Exception thrown when service or characteristic discovery fails.
class RayTempServiceException extends RayTempException {
  /// The service or characteristic UUID that was not found.
  final String? uuid;

  const RayTempServiceException(
    super.message, [
    this.uuid,
    super.cause,
  ]);

  @override
  String toString() => 'RayTempServiceException: $message${uuid != null ? ' (UUID: $uuid)' : ''}';
}

/// Exception thrown when data parsing fails.
class RayTempDataException extends RayTempException {
  /// The raw data that failed to parse.
  final List<int>? rawData;

  const RayTempDataException(
    super.message, [
    this.rawData,
    super.cause,
  ]);

  @override
  String toString() => 'RayTempDataException: $message${rawData != null ? ' (Raw data: $rawData)' : ''}';
}
