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
