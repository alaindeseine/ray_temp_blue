## 2.0.0

### Breaking changes

* **`TemperatureReading.value` is now in the device's current display
  unit, not always Celsius.** Previously the package re-converted
  Fahrenheit readings to Celsius before exposing them, which forced
  consumers to call `toOriginalUnit()` / `toUnit()` just to get back
  what the thermometer displays. Starting with 2.0.0, `value` holds the
  reading as the device sent it (°C when the device is set to Celsius,
  °F when set to Fahrenheit), and `originalUnit` matches it. Code that
  reads `reading.value` and treated it as Celsius must now call
  `reading.toCelsius()` explicitly.
* `TemperatureReading.toCelsius()` and `toFahrenheit()` now convert from
  `originalUnit` to the target unit (previously `toCelsius()` returned
  `value` unchanged and `toFahrenheit()` always applied a C→F conversion).
* `TemperatureReading.toOriginalUnit()` now simply returns `value`
  (previously it converted). The method is kept for API compatibility;
  prefer reading `value` directly.
* `TemperatureReading.toString()` now uses `originalUnit.symbol`
  (previously hard-coded `°C`).

### Migration

```dart
// Before (1.x) — value was always Celsius
final c = reading.value;              // °C regardless of device unit
final f = reading.toOriginalUnit();   // °F if device in °F, else °C

// After (2.0) — value is in originalUnit
final native = reading.value;         // °C or °F, matches originalUnit
final c = reading.toCelsius();        // explicit convert
final f = reading.toFahrenheit();     // explicit convert
```

### Tests

* Rewrote the `TemperatureReading` conversion suite to exercise both
  source units (°C and °F) for `toCelsius`, `toFahrenheit`, `toKelvin`,
  `toUnit` and `toString`. Total: 21 tests, all passing.

## 1.1.1

### Fixed

* **BLE write mode on the instrument settings characteristic (…AD709).**
  The BlueTherm firmware exposes the settings characteristic in
  `writeWithoutResponse` mode only, while the command characteristic
  (…AD705) exposes `write` (with response). The previous release called
  `write(bytes)` on both, which raised `PlatformException: The WRITE
  property is not supported by this BLE characteristic` the first time
  `setDeviceUnit()` (or the connect-time `preferredUnit` sync) tried to
  update the device. Both `RayTempBlue` and `RayTempBlueHold` now pick
  the write mode from the characteristic's advertised GATT properties,
  so `setDeviceUnit()` and `preferredUnit` work on the real hardware.

## 1.1.0

### Features

* **Device/app unit synchronization** — new API to keep the thermometer's
  physical display in sync with the user's app preference:
  * `RayTempBlue({TemperatureUnit? preferredUnit})` and
    `RayTempBlueHold({TemperatureUnit? preferredUnit})` constructors —
    the device is reconfigured on connect only when its current unit
    differs from `preferredUnit`
  * `deviceUnit` getter — read the unit currently stored on the thermometer
  * `setDeviceUnit(TemperatureUnit unit)` — change the device unit at
    runtime, with a write-only-if-different guard that preserves the
    thermometer's 10,000-cycle flash memory
  * `TemperatureReading.toUnit(TemperatureUnit unit)` — generic
    conversion helper (alongside the existing `toCelsius` / `toFahrenheit`
    / `toKelvin`)

### Changed

* **BLE backend swapped from `flutter_blue_plus` to `flutter_blue_ultra`**
  (BSD-3-Clause fork of `flutter_blue_plus` 1.x by Intent). The
  `flutter_blue_plus` 2.x license switched to a restrictive model
  requiring paid commercial licenses for all for-profit use.
  `flutter_blue_ultra` keeps the familiar 1.x API under BSD, so no
  licensing trap for consumers of this package.
* `permission_handler` bumped: `^12.0.1` → `^13.0.2`.
* Minimum Flutter SDK: `>=3.0.0` → `>=3.32.0` (required by `flutter_lints`
  6, aligned across root and example packages).
* `example/pubspec.yaml`: `flutter_lints` `^5.0.0` → `^6.0.0`.

### Compatibility

* **Public API unchanged**: `RayTempBlue`, `RayTempBlueHold`,
  `RayTempDevice`, `TemperatureReading`, `TemperatureUnit`, and the full
  `RayTempException` hierarchy keep their existing signatures. New
  constructor parameters are optional with safe defaults.
* Downstream apps that only consumed this package's API need no code
  changes. Apps that imported `flutter_blue_plus` directly alongside this
  package must switch their own import to `flutter_blue_ultra`
  (`flutter_blue_ultra` and `flutter_blue_plus` cannot coexist in the
  same project).

### Tests

* Added 5 unit tests covering `TemperatureReading.toUnit()` and both
  constructors (with and without `preferredUnit`). Total: 21 tests, all
  passing.

## 1.0.1+stable

### Maintenance Release

* Updated `flutter_lints` to ^6.0.0
* Added MIT license
* Fixed repository URLs in pubspec.yaml
* Package cleanup for pub.dev publication

## 1.0.0+stable

### Stable Release - Production Ready

* **Connection Status Monitoring**
  * Real-time connection status stream via `connectionStatusStream`
  * Automatic connection loss detection and recovery
  * Visual connection status indicators in example app

* **Automatic Reconnection (HOLD Mode)**
  * Automatic reconnection every 10 seconds when connection is lost
  * MAC address-based reconnection for faster pairing
  * Smart reconnection only when device was previously connected

* **Enhanced Connection Methods**
  * `scanAndConnectFirst()` - Scan and connect to first device found
  * `connectByMacAddress(String macAddress)` - Direct connection by MAC address
  * Improved connection reliability and error handling

* **Example App Improvements**
  * Integrated mode selector with connection status display
  * Real-time Bluetooth connection indicator (green/red)
  * Automatic reconnection status messages
  * Enhanced user experience with visual feedback

* **Bug Fixes**
  * Fixed HOLD mode implementation - no longer activates sensor notifications
  * Resolved overflow issues in example app with scrollable interface
  * Improved error handling and user feedback

* **Dependencies Updated**
  * flutter_blue_plus: ^1.35.5 (was ^1.32.12)
  * permission_handler: ^12.0.1 (was ^11.3.1)

### Breaking Changes
* HOLD mode now works correctly by reading sensor manually instead of using notifications
* Connection status monitoring requires listening to `connectionStatusStream`

## 0.1.0

### Initial Release

* **Core Features**
  * Bluetooth LE communication with Ray Temp Blue thermometer devices
  * Automatic temperature capture when device button is pressed
  * Real-time temperature streaming via `Stream<TemperatureReading>`
  * Device discovery and connection management
  * Manual measurement triggering
  * Device identification (LED flashing)

* **Permission Management**
  * Automatic Bluetooth permission handling for Android
  * Support for both Android < 12 and Android ≥ 12 permission models
  * Comprehensive permission verification with `verifyPermissions()` method

* **Temperature Handling**
  * Support for Celsius and Fahrenheit units
  * Temperature conversion methods (toCelsius, toFahrenheit, toKelvin)
  * Preservation of original device unit information
  * IEEE-754 32-bit float parsing (Little Endian)

* **Error Handling**
  * Comprehensive exception hierarchy for different error types
  * Specific exceptions for permissions, connections, sensors, and data parsing
  * Sensor error detection (0xFFFFFFFF error code handling)

* **BlueTherm LE Protocol**
  * Full implementation of ETI's BlueTherm LE protocol
  * Service UUID: `455449424C5545544845524DB87AD700`
  * Sensor reading characteristic: `455449424C5545544845524DB87AD701`
  * Command/notification characteristic: `455449424C5545544845524DB87AD705`
  * Instrument settings reading for unit detection

* **Example Application**
  * Complete example app demonstrating all features
  * Device scanning and selection UI
  * Real-time temperature display
  * Connection management
  * Error handling demonstration

* **Testing**
  * Comprehensive unit tests for all models and utilities
  * Exception testing
  * Temperature conversion testing
  * Device identification testing

* **Documentation**
  * Complete API documentation
  * Usage examples and best practices
  * Android configuration guide
  * Error handling guide
