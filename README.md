# Ray Temp Blue

A Flutter package for interfacing with Ray Temp Blue Bluetooth LE thermometer devices. This package allows you to automatically capture temperature measurements when the device button is pressed and stream them to your Flutter application.

## Features

- 🌡️ **Two operation modes** - Continuous mode and HOLD mode for different use cases
- 📱 **Easy device discovery** - Scan and connect to Ray Temp Blue devices
- 🔄 **Real-time streaming** - Stream temperature readings to your app
- 🛡️ **Permission handling** - Automatic Bluetooth permission management for Android
- 🎯 **Manual triggering** - Programmatically trigger measurements
- 🔍 **Device identification** - Make the device flash its LEDs for identification
- 📊 **Unit conversion** - Support for Celsius and Fahrenheit with conversion methods
- ⚡ **Exception handling** - Comprehensive error handling with specific exception types
- 🔌 **Connection monitoring** - Real-time connection status with automatic reconnection
- 🔄 **Auto-reconnection** - Intelligent reconnection when connection is lost (HOLD mode)
- 📍 **MAC address connection** - Direct connection by device MAC address

### Operation Modes

**Continuous Mode (`RayTempBlue`)**
- Automatic continuous temperature measurements
- Real-time temperature updates in your app
- Ideal for monitoring applications

**HOLD Mode (`RayTempBlueHold`)**
- Manual measurements only (button press or programmatic trigger)
- Maintains the device's original HOLD behavior
- Ideal for on-demand measurements

## Supported Devices

This package is designed for Ray Temp Blue infrared thermometer devices that use the BlueTherm LE protocol:

- Ray Temp Blue (ETI Ltd)
- Temperature range: -50°C to 350°C
- Bluetooth LE with ETI's proprietary protocol

## Getting Started

### Prerequisites

- Flutter 3.0.0 or higher
- Android device with Bluetooth LE support
- Ray Temp Blue thermometer device

### Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  ray_temp_blue: ^1.0.0
```

### Android Configuration

The package automatically handles Bluetooth permissions, but you need to ensure your `android/app/src/main/AndroidManifest.xml` includes the necessary permissions:

```xml
<!-- Bluetooth permissions for Android < 12 -->
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30" />

<!-- Bluetooth permissions for Android >= 12 -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<!-- Declare that the app uses Bluetooth LE -->
<uses-feature android:name="android.hardware.bluetooth_le" android:required="true"/>
```

## Usage

### Continuous Mode Example

```dart
import 'package:ray_temp_blue/ray_temp_blue.dart';

class ContinuousTemperatureScreen extends StatefulWidget {
  @override
  _ContinuousTemperatureScreenState createState() => _ContinuousTemperatureScreenState();
}

class _ContinuousTemperatureScreenState extends State<ContinuousTemperatureScreen> {
  final RayTempBlue _rayTempBlue = RayTempBlue();
  final TextEditingController _temperatureController = TextEditingController();
  StreamSubscription<TemperatureReading>? _temperatureSubscription;

  @override
  void initState() {
    super.initState();
    _initializeDevice();
  }

  Future<void> _initializeDevice() async {
    try {
      // Verify permissions
      await _rayTempBlue.verifyPermissions();

      // Scan for devices
      final devices = await _rayTempBlue.scanDevices();

      if (devices.isNotEmpty) {
        // Connect to the first device found
        await _rayTempBlue.connect(devices.first);

        // Listen to continuous temperature readings
        _temperatureSubscription = _rayTempBlue.temperatureStream.listen(
          (reading) {
            setState(() {
              _temperatureController.text = '${reading.value.toStringAsFixed(1)}°C';
            });
          },
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Continuous Temperature Monitor')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _temperatureController,
              decoration: InputDecoration(
                labelText: 'Temperature (Live)',
                suffixText: '°C',
              ),
              readOnly: true,
            ),
            Text('Temperature updates automatically'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _temperatureSubscription?.cancel();
    _rayTempBlue.dispose();
    super.dispose();
  }
}
```

### HOLD Mode Example

```dart
import 'package:ray_temp_blue/ray_temp_blue.dart';

class HoldTemperatureScreen extends StatefulWidget {
  @override
  _HoldTemperatureScreenState createState() => _HoldTemperatureScreenState();
}

class _HoldTemperatureScreenState extends State<HoldTemperatureScreen> {
  final RayTempBlueHold _rayTempBlue = RayTempBlueHold();
  final TextEditingController _temperatureController = TextEditingController();
  StreamSubscription<TemperatureReading>? _temperatureSubscription;

  @override
  void initState() {
    super.initState();
    _initializeDevice();
  }

  Future<void> _initializeDevice() async {
    try {
      // Verify permissions
      await _rayTempBlue.verifyPermissions();

      // Scan for devices
      final devices = await _rayTempBlue.scanDevices();

      if (devices.isNotEmpty) {
        // Connect to the first device found
        await _rayTempBlue.connect(devices.first);

        // Listen to temperature readings (only when button pressed)
        _temperatureSubscription = _rayTempBlue.temperatureStream.listen(
          (reading) {
            setState(() {
              _temperatureController.text = '${reading.value.toStringAsFixed(1)}°C';
            });
          },
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _takeMeasurement() async {
    try {
      final reading = await _rayTempBlue.triggerMeasurement();
      setState(() {
        _temperatureController.text = '${reading.value.toStringAsFixed(1)}°C';
      });
    } catch (e) {
      print('Measurement error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HOLD Mode Temperature')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _temperatureController,
              decoration: InputDecoration(
                labelText: 'Temperature (On Demand)',
                suffixText: '°C',
              ),
              readOnly: true,
            ),
            ElevatedButton(
              onPressed: _takeMeasurement,
              child: Text('Take Measurement'),
            ),
            Text('Or press the device button'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _temperatureSubscription?.cancel();
    _rayTempBlue.dispose();
    super.dispose();
  }
}
```

### Advanced Usage

#### Device Discovery and Selection

```dart
// Scan for available devices
final devices = await rayTempBlue.scanDevices(timeout: Duration(seconds: 10));

// Display devices to user for selection
for (final device in devices) {
  print('Found: ${device.name} (${device.serialNumber}) - ${device.rssi}dBm');
}

// Connect to selected device
await rayTempBlue.connect(selectedDevice);
```

#### Temperature Unit Handling

```dart
rayTempBlue.temperatureStream.listen((reading) {
  print('Temperature: ${reading.value.toStringAsFixed(1)}°C');
  print('In Fahrenheit: ${reading.toFahrenheit().toStringAsFixed(1)}°F');
  print('In Kelvin: ${reading.toKelvin().toStringAsFixed(1)}K');
  print('Original unit: ${reading.originalUnit.displayName}');
  print('Timestamp: ${reading.timestamp}');
});
```

#### Connection Status Monitoring

```dart
// Monitor connection status in real-time (HOLD mode only)
rayTempBlueHold.connectionStatusStream.listen((isConnected) {
  if (isConnected) {
    print('Device connected');
    updateUI(connectionStatus: 'Connected');
  } else {
    print('Device disconnected');
    updateUI(connectionStatus: 'Disconnected - Reconnecting...');
  }
});
```

#### Automatic Reconnection

```dart
// Automatic reconnection by MAC address (HOLD mode)
String savedMacAddress = 'AA:BB:CC:DD:EE:FF';

try {
  await rayTempBlueHold.connectByMacAddress(savedMacAddress);
  print('Reconnected successfully');
} catch (e) {
  print('Reconnection failed: $e');
}

// Scan and connect to first device found
final device = await rayTempBlueHold.scanAndConnectFirst();
if (device != null) {
  print('Auto-connected to: ${device.name}');
  // Save MAC address for future reconnections
  savedMacAddress = device.address;
}
```

#### Error Handling

```dart
try {
  await rayTempBlue.connect(device);
} on RayTempPermissionException catch (e) {
  print('Permission error: ${e.message}');
  print('Missing permissions: ${e.missingPermissions}');
} on RayTempConnectionException catch (e) {
  print('Connection error: ${e.message}');
  if (e.deviceAddress != null) {
    print('Failed device: ${e.deviceAddress}');
  }
} on RayTempSensorException catch (e) {
  print('Sensor error: ${e.message}');
  if (e.errorCode != null) {
    print('Error code: 0x${e.errorCode!.toRadixString(16)}');
  }
} catch (e) {
  print('Unexpected error: $e');
}
```

## API Reference

### RayTempBlue (Continuous Mode)

Main class for continuous temperature monitoring.

#### Properties

- `Stream<TemperatureReading> temperatureStream` - Stream of temperature readings
- `bool isConnected` - Whether a device is currently connected
- `RayTempDevice? connectedDevice` - Currently connected device information

#### Methods

- `Future<void> verifyPermissions()` - Verify and request Bluetooth permissions
- `Future<List<RayTempDevice>> scanDevices({Duration timeout})` - Scan for devices
- `Future<void> connect(RayTempDevice device)` - Connect to a specific device
- `Future<void> disconnect()` - Disconnect from current device
- `Future<void> triggerMeasurement()` - Manually trigger a measurement
- `Future<void> identifyDevice()` - Make device flash LEDs for identification
- `void dispose()` - Clean up resources

### RayTempBlueHold (HOLD Mode)

Class for manual temperature measurements with connection monitoring.

#### Properties

- `Stream<TemperatureReading> temperatureStream` - Stream of temperature readings (manual only)
- `Stream<bool> connectionStatusStream` - Stream of connection status changes
- `bool isConnected` - Whether a device is currently connected
- `bool isWaitingForMeasurement` - Whether a measurement is in progress
- `RayTempDevice? connectedDevice` - Currently connected device information

#### Methods

- `Future<void> verifyPermissions()` - Verify and request Bluetooth permissions
- `Future<List<RayTempDevice>> scanDevices({Duration timeout})` - Scan for devices
- `Future<RayTempDevice?> scanAndConnectFirst({Duration timeout})` - Scan and auto-connect to first device
- `Future<void> connect(RayTempDevice device)` - Connect to a specific device
- `Future<void> connectByMacAddress(String macAddress, {Duration timeout})` - Connect by MAC address
- `Future<void> disconnect()` - Disconnect from current device
- `Future<TemperatureReading> triggerMeasurement()` - Manually trigger and return measurement
- `Future<void> identifyDevice()` - Make device flash LEDs for identification
- `void dispose()` - Clean up resources

### TemperatureReading

Represents a temperature measurement from the device.

#### Properties

- `double value` - Temperature value in Celsius
- `TemperatureUnit originalUnit` - Original unit from the device
- `DateTime timestamp` - When the measurement was taken

#### Methods

- `double toCelsius()` - Convert to Celsius (returns value as-is)
- `double toFahrenheit()` - Convert to Fahrenheit
- `double toKelvin()` - Convert to Kelvin
- `double toOriginalUnit()` - Convert to the device's original unit

### RayTempDevice

Represents a discovered Ray Temp Blue device.

#### Properties

- `BluetoothDevice device` - Underlying Bluetooth device
- `String name` - Device name
- `String serialNumber` - Device serial number
- `int rssi` - Signal strength when discovered
- `String address` - Device MAC address
- `bool isConnected` - Current connection status

## Exception Types

The package provides specific exception types for different error scenarios:

- `RayTempPermissionException` - Bluetooth permission issues
- `RayTempBluetoothException` - Bluetooth not available or disabled
- `RayTempConnectionException` - Device connection failures
- `RayTempSensorException` - Sensor errors (e.g., error code 0xFFFFFFFF)
- `RayTempScanException` - Device scanning failures
- `RayTempServiceException` - Bluetooth service/characteristic not found
- `RayTempDataException` - Data parsing errors

## Example App

See the `/example` folder for a complete example application that demonstrates:

- **Mode Selection** - Switch between Continuous and HOLD modes
- **Device scanning and selection** - Automatic device discovery
- **Connection management** - Real-time connection status monitoring
- **Auto-reconnection** - Automatic reconnection when connection is lost (HOLD mode)
- **Real-time temperature display** - Live temperature updates
- **Manual measurement triggering** - On-demand temperature readings
- **Device identification** - LED flashing for device identification
- **Visual status indicators** - Connection status with color-coded icons
- **Error handling** - Comprehensive error management and user feedback

### Running the Example

```bash
cd example
flutter run lib/main.dart
```

The example app includes:
- **Integrated mode selector** with visual indicators
- **Real-time Bluetooth connection status** (green/red icons)
- **Automatic reconnection** in HOLD mode
- **Scrollable interface** to prevent overflow issues
- **Professional UI** suitable for production use

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and feature requests, please use the [GitHub issue tracker](https://github.com/your-org/ray_temp_blue/issues).
