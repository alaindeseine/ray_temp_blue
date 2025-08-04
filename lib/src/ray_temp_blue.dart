import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'models/temperature_reading.dart';
import 'models/ray_temp_device.dart';
import 'exceptions/ray_temp_exceptions.dart';

/// Main class for interfacing with Ray Temp Blue Bluetooth LE thermometer.
class RayTempBlue {
  // BlueTherm LE Protocol UUIDs (formatted as standard 128-bit UUIDs)
  static const String _serviceUuid = '45544942-4C55-4554-4845-524DB87AD700';
  static const String _sensor1ReadingUuid = '45544942-4C55-4554-4845-524DB87AD701';
  static const String _commandNotificationUuid = '45544942-4C55-4554-4845-524DB87AD705';
  static const String _instrumentSettingsUuid = '45544942-4C55-4554-4845-524DB87AD709';

  // Command/Notification codes
  static const int _buttonPressedNotification = 0x0001;
  static const int _measureCommand = 0x0010;
  static const int _identifyCommand = 0x0020;

  // Error codes
  static const int _sensorErrorCode = 0xFFFFFFFF;

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _sensor1Characteristic;
  BluetoothCharacteristic? _commandCharacteristic;
  BluetoothCharacteristic? _settingsCharacteristic;

  final StreamController<TemperatureReading> _temperatureController = 
      StreamController<TemperatureReading>.broadcast();
  
  StreamSubscription<List<int>>? _sensor1Subscription;
  StreamSubscription<List<int>>? _commandSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  bool _isConnected = false;
  TemperatureUnit _currentUnit = TemperatureUnit.celsius;

  /// Stream of temperature readings from the device.
  Stream<TemperatureReading> get temperatureStream => _temperatureController.stream;

  /// Whether the device is currently connected.
  bool get isConnected => _isConnected;

  /// The currently connected device, if any.
  RayTempDevice? get connectedDevice {
    if (_connectedDevice == null) return null;
    return RayTempDevice(
      device: _connectedDevice!,
      name: _connectedDevice!.platformName,
      serialNumber: RayTempDevice.extractSerialNumber(_connectedDevice!.platformName),
      rssi: 0, // RSSI not available when connected
    );
  }

  /// Verifies and requests necessary Bluetooth permissions.
  /// 
  /// This method handles the different permission requirements for different
  /// Android versions automatically.
  /// 
  /// Throws [RayTempPermissionException] if permissions are denied.
  /// Throws [RayTempBluetoothException] if Bluetooth is not supported or disabled.
  Future<void> verifyPermissions() async {
    // Check if Bluetooth is supported
    if (!await FlutterBluePlus.isSupported) {
      throw const RayTempBluetoothException('Bluetooth is not supported on this device');
    }

    // Check if Bluetooth is enabled
    final bluetoothState = await FlutterBluePlus.adapterState.first;
    if (bluetoothState != BluetoothAdapterState.on) {
      throw const RayTempBluetoothException('Bluetooth is disabled. Please enable Bluetooth and try again.');
    }

    final List<String> missingPermissions = [];
    
    if (Platform.isAndroid) {
      // For Android 12+ (API 31+)
      if (await _isAndroid12OrHigher()) {
        final bluetoothScan = await Permission.bluetoothScan.status;
        final bluetoothConnect = await Permission.bluetoothConnect.status;
        
        if (!bluetoothScan.isGranted) {
          missingPermissions.add('BLUETOOTH_SCAN');
        }
        if (!bluetoothConnect.isGranted) {
          missingPermissions.add('BLUETOOTH_CONNECT');
        }
        
        if (missingPermissions.isNotEmpty) {
          final Map<Permission, PermissionStatus> results = await [
            Permission.bluetoothScan,
            Permission.bluetoothConnect,
          ].request();
          
          missingPermissions.clear();
          if (results[Permission.bluetoothScan] != PermissionStatus.granted) {
            missingPermissions.add('BLUETOOTH_SCAN');
          }
          if (results[Permission.bluetoothConnect] != PermissionStatus.granted) {
            missingPermissions.add('BLUETOOTH_CONNECT');
          }
        }
      } else {
        // For Android < 12
        final location = await Permission.location.status;
        final bluetooth = await Permission.bluetooth.status;
        
        if (!location.isGranted) {
          missingPermissions.add('ACCESS_FINE_LOCATION');
        }
        if (!bluetooth.isGranted) {
          missingPermissions.add('BLUETOOTH');
        }
        
        if (missingPermissions.isNotEmpty) {
          final Map<Permission, PermissionStatus> results = await [
            Permission.location,
            Permission.bluetooth,
          ].request();
          
          missingPermissions.clear();
          if (results[Permission.location] != PermissionStatus.granted) {
            missingPermissions.add('ACCESS_FINE_LOCATION');
          }
          if (results[Permission.bluetooth] != PermissionStatus.granted) {
            missingPermissions.add('BLUETOOTH');
          }
        }
      }
    }

    if (missingPermissions.isNotEmpty) {
      throw RayTempPermissionException(
        'Required Bluetooth permissions are missing',
        missingPermissions,
      );
    }
  }

  /// Checks if the device is running Android 12 or higher.
  Future<bool> _isAndroid12OrHigher() async {
    if (!Platform.isAndroid) return false;

    // This is a simplified check. In a real implementation, you might want to
    // use a more robust method to check the Android API level.
    try {
      await Permission.bluetoothScan.status;
      return true; // If bluetoothScan permission exists, it's Android 12+
    } catch (e) {
      return false; // If it doesn't exist, it's Android < 12
    }
  }

  /// Scans for Ray Temp Blue devices.
  /// 
  /// Returns a list of discovered devices. The scan will run for [timeout] duration.
  /// 
  /// Throws [RayTempPermissionException] if permissions are missing.
  /// Throws [RayTempScanException] if scanning fails.
  Future<List<RayTempDevice>> scanDevices({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await verifyPermissions();

    final List<RayTempDevice> devices = [];
    final Completer<void> completer = Completer<void>();

    try {
      // Listen for scan results
      final subscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          final deviceName = result.device.platformName;
          if (RayTempDevice.isRayTempBlue(deviceName)) {
            final device = RayTempDevice.fromScanResult(result);
            // Avoid duplicates
            if (!devices.any((d) => d.address == device.address)) {
              devices.add(device);
            }
          }
        }
      });

      // Start scanning
      await FlutterBluePlus.startScan(timeout: timeout);

      // Wait for scan to complete
      Timer(timeout, () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      await completer.future;
      await subscription.cancel();
      await FlutterBluePlus.stopScan();

      return devices;
    } catch (e) {
      throw RayTempScanException('Failed to scan for devices', e);
    }
  }

  /// Connects to a specific Ray Temp Blue device.
  /// 
  /// Throws [RayTempConnectionException] if connection fails.
  /// Throws [RayTempServiceException] if required services are not found.
  Future<void> connect(RayTempDevice device) async {
    if (_isConnected) {
      await disconnect();
    }

    try {
      // Connect to device
      await device.device.connect(timeout: const Duration(seconds: 15));
      _connectedDevice = device.device;

      // Listen for connection state changes
      _connectionSubscription = device.device.connectionState.listen((state) {
        _isConnected = state == BluetoothConnectionState.connected;
        if (!_isConnected) {
          _cleanup();
        }
      });

      // Discover services
      final services = await device.device.discoverServices();
      
      // Find the BlueTherm service
      BluetoothService? bluetoothService;

      for (final service in services) {
        if (service.uuid.toString().toUpperCase() == _serviceUuid.toUpperCase()) {
          bluetoothService = service;
          break;
        }
      }

      if (bluetoothService == null) {
        throw RayTempServiceException(
          'BlueTherm service not found. Available services: ${services.map((s) => s.uuid.toString()).join(', ')}',
          _serviceUuid,
        );
      }

      // Find required characteristics
      for (final characteristic in bluetoothService.characteristics) {
        final uuid = characteristic.uuid.toString().toUpperCase();
        
        if (uuid == _sensor1ReadingUuid.toUpperCase()) {
          _sensor1Characteristic = characteristic;
        } else if (uuid == _commandNotificationUuid.toUpperCase()) {
          _commandCharacteristic = characteristic;
        } else if (uuid == _instrumentSettingsUuid.toUpperCase()) {
          _settingsCharacteristic = characteristic;
        }
      }

      if (_sensor1Characteristic == null) {
        throw const RayTempServiceException(
          'Sensor 1 reading characteristic not found',
          _sensor1ReadingUuid,
        );
      }

      if (_commandCharacteristic == null) {
        throw const RayTempServiceException(
          'Command/notification characteristic not found',
          _commandNotificationUuid,
        );
      }

      // Read current instrument settings to get temperature unit
      await _readInstrumentSettings();

      // Enable notifications
      await _enableNotifications();

      _isConnected = true;
    } catch (e) {
      _cleanup();
      if (e is RayTempException) {
        rethrow;
      }
      throw RayTempConnectionException(
        'Failed to connect to device',
        device.address,
        e,
      );
    }
  }

  /// Disconnects from the currently connected device.
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
    }
    _cleanup();
  }

  /// Manually triggers a measurement on the device.
  /// 
  /// This is equivalent to pressing the button on the device.
  /// 
  /// Throws [RayTempConnectionException] if not connected.
  Future<void> triggerMeasurement() async {
    if (!_isConnected || _commandCharacteristic == null) {
      throw const RayTempConnectionException('Device not connected');
    }

    try {
      final command = _encodeCommand(_measureCommand);
      await _commandCharacteristic!.write(command);
    } catch (e) {
      throw RayTempConnectionException('Failed to trigger measurement', null, e);
    }
  }

  /// Makes the device identify itself by flashing its LEDs.
  /// 
  /// Throws [RayTempConnectionException] if not connected.
  Future<void> identifyDevice() async {
    if (!_isConnected || _commandCharacteristic == null) {
      throw const RayTempConnectionException('Device not connected');
    }

    try {
      final command = _encodeCommand(_identifyCommand);
      await _commandCharacteristic!.write(command);
    } catch (e) {
      throw RayTempConnectionException('Failed to identify device', null, e);
    }
  }

  /// Disposes of resources and closes streams.
  void dispose() {
    disconnect();
    _temperatureController.close();
  }

  /// Reads the instrument settings to determine the current temperature unit.
  Future<void> _readInstrumentSettings() async {
    if (_settingsCharacteristic == null) return;

    try {
      final data = await _settingsCharacteristic!.read();
      if (data.isNotEmpty) {
        // First byte contains the units: 0x00 = °C, 0x01 = °F
        final unitByte = data[0];
        _currentUnit = unitByte == 0x01
            ? TemperatureUnit.fahrenheit
            : TemperatureUnit.celsius;
      }
    } catch (e) {
      // If we can't read settings, default to Celsius
      _currentUnit = TemperatureUnit.celsius;
    }
  }

  /// Enables notifications for sensor readings and commands.
  Future<void> _enableNotifications() async {
    // Enable sensor 1 notifications
    if (_sensor1Characteristic != null) {
      await _sensor1Characteristic!.setNotifyValue(true);
      _sensor1Subscription = _sensor1Characteristic!.lastValueStream.listen(
        _handleSensorReading,
        onError: (error) {
          _temperatureController.addError(
            RayTempDataException('Error reading sensor data', null, error),
          );
        },
      );
    }

    // Enable command/notification notifications
    if (_commandCharacteristic != null) {
      await _commandCharacteristic!.setNotifyValue(true);
      _commandSubscription = _commandCharacteristic!.lastValueStream.listen(
        _handleCommandNotification,
        onError: (error) {
          // Command notifications are less critical, just log the error
        },
      );
    }
  }

  /// Handles incoming sensor reading data.
  void _handleSensorReading(List<int> data) {
    try {
      if (data.length < 4) {
        throw const RayTempDataException('Insufficient sensor data received');
      }

      // Parse IEEE-754 32-bit float (Little Endian)
      final bytes = Uint8List.fromList(data.take(4).toList());
      final byteData = ByteData.sublistView(bytes);
      final rawValue = byteData.getFloat32(0, Endian.little);

      // Check for sensor error
      if (rawValue.isNaN || rawValue.isInfinite ||
          byteData.getUint32(0, Endian.little) == _sensorErrorCode) {
        throw const RayTempSensorException(
          'Sensor error detected',
          _sensorErrorCode,
        );
      }

      // Convert to Celsius if needed
      double temperatureInCelsius = rawValue;
      if (_currentUnit == TemperatureUnit.fahrenheit) {
        temperatureInCelsius = (rawValue - 32) * 5 / 9;
      }

      // Create temperature reading
      final reading = TemperatureReading(
        value: temperatureInCelsius,
        originalUnit: _currentUnit,
        timestamp: DateTime.now(),
      );

      _temperatureController.add(reading);
    } catch (e) {
      if (e is RayTempException) {
        _temperatureController.addError(e);
      } else {
        _temperatureController.addError(
          RayTempDataException('Failed to parse sensor data', data, e),
        );
      }
    }
  }

  /// Handles incoming command/notification data.
  void _handleCommandNotification(List<int> data) {
    if (data.length < 2) return;

    // Parse uint16 (Little Endian)
    final bytes = Uint8List.fromList(data.take(2).toList());
    final byteData = ByteData.sublistView(bytes);
    final notification = byteData.getUint16(0, Endian.little);

    // Handle button pressed notification
    if (notification == _buttonPressedNotification) {
      // Button was pressed, measurement will follow automatically
      // No additional action needed as sensor reading will be handled
      // by _handleSensorReading
    }
  }

  /// Encodes a command as uint16 Little Endian.
  List<int> _encodeCommand(int command) {
    final byteData = ByteData(2);
    byteData.setUint16(0, command, Endian.little);
    return byteData.buffer.asUint8List();
  }

  /// Cleans up resources and subscriptions.
  void _cleanup() {
    _isConnected = false;
    _connectedDevice = null;
    _sensor1Characteristic = null;
    _commandCharacteristic = null;
    _settingsCharacteristic = null;

    _sensor1Subscription?.cancel();
    _sensor1Subscription = null;

    _commandSubscription?.cancel();
    _commandSubscription = null;

    _connectionSubscription?.cancel();
    _connectionSubscription = null;
  }
}
