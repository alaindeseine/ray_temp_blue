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
