# Development Guide

## Project Structure

```
lib/
├── ray_temp_blue.dart              # Main export file
└── src/
    ├── ray_temp_blue.dart          # Main RayTempBlue class
    ├── models/
    │   ├── temperature_reading.dart # Temperature data model
    │   └── ray_temp_device.dart    # Device representation
    └── exceptions/
        └── ray_temp_exceptions.dart # Custom exceptions

example/                            # Example application
test/                              # Unit tests
android/                           # Android-specific configuration
docs/                             # Documentation
```

## BlueTherm LE Protocol Implementation

### Service and Characteristics

- **Service UUID**: `455449424C5545544845524DB87AD700`
- **Sensor 1 Reading**: `455449424C5545544845524DB87AD701` (Read & Notify)
- **Commands/Notifications**: `455449424C5545544845524DB87AD705` (Read/Write & Notify)
- **Instrument Settings**: `455449424C5545544845524DB87AD709` (Read/Write)

### Data Formats

#### Temperature Reading (Sensor 1)
- **Format**: IEEE-754 32-bit floating point (Little Endian)
- **Error Value**: `0xFFFFFFFF` indicates sensor error
- **Range**: -50°C to 350°C for Ray Temp Blue

#### Commands/Notifications
- **Format**: uint16 (Little Endian)
- **Button Pressed**: `0x0001`
- **Manual Measure**: `0x0010`
- **Identify Device**: `0x0020`

#### Instrument Settings
- **Offset 0**: Units (0x00 = °C, 0x01 = °F)
- **Offset 1-2**: Measurement interval (uint16, Little Endian)
- **Offset 3-4**: Auto-off interval (uint16, Little Endian)

## Development Setup

### Prerequisites

1. Flutter SDK 3.0.0+
2. Android Studio or VS Code
3. Ray Temp Blue device for testing

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

### Running Example

```bash
cd example
flutter run
```

## Testing Strategy

### Unit Tests
- Model classes (TemperatureReading, RayTempDevice)
- Exception classes
- Utility functions

### Integration Tests
- Bluetooth communication (requires physical device)
- Permission handling
- Data parsing

### Manual Testing
- Device discovery
- Connection/disconnection
- Temperature measurement
- Error scenarios

## Adding New Features

### 1. Extending Protocol Support

To add support for additional BlueTherm LE characteristics:

1. Add new UUIDs to `RayTempBlue` class constants
2. Implement characteristic discovery in `connect()` method
3. Add notification handling in `_enableNotifications()`
4. Create appropriate data parsing methods

### 2. Adding New Device Types

To support other ETI devices (ThermaQ Blue, BlueTherm One, etc.):

1. Update `RayTempDevice.isRayTempBlue()` method
2. Add device-specific identification logic
3. Handle device-specific characteristics (e.g., Sensor 2 for dual-input devices)

### 3. Platform Support

To add iOS support:

1. Add iOS-specific permission handling in `verifyPermissions()`
2. Update example app with iOS configuration
3. Test on iOS devices

## Code Style

- Follow Dart/Flutter conventions
- Use meaningful variable and method names
- Add comprehensive documentation comments
- Handle errors gracefully with specific exceptions
- Write tests for new functionality

## Release Process

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md` with new features/fixes
3. Run tests and analysis
4. Update documentation if needed
5. Create git tag
6. Publish to pub.dev (when ready)

## Debugging Tips

### Bluetooth Issues
- Check device permissions in Android settings
- Verify Bluetooth is enabled
- Use `flutter logs` to see detailed error messages
- Test with multiple devices if available

### Connection Problems
- Ensure device is not connected to another app
- Check signal strength (RSSI)
- Verify device is in range
- Try restarting Bluetooth on the phone

### Data Parsing Issues
- Log raw data bytes for analysis
- Verify Little Endian byte order
- Check for sensor error codes (0xFFFFFFFF)
- Validate data length before parsing

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Ensure all tests pass
5. Update documentation
6. Submit pull request

## Resources

- [BlueTherm LE Protocol Specification](../specifications_ray_temp_blue.md)
- [Flutter Blue Plus Documentation](https://pub.dev/packages/flutter_blue_plus)
- [Permission Handler Documentation](https://pub.dev/packages/permission_handler)
- [ETI Ltd Official Website](https://www.etiltd.com/)
