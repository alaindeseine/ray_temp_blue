/// Represents a temperature reading from the Ray Temp Blue device.
class TemperatureReading {
  /// The temperature value in Celsius.
  final double value;
  
  /// The original unit from the device.
  final TemperatureUnit originalUnit;
  
  /// The timestamp when the measurement was taken.
  final DateTime timestamp;

  /// Creates a new temperature reading.
  const TemperatureReading({
    required this.value,
    required this.originalUnit,
    required this.timestamp,
  });

  /// Converts the temperature to Celsius.
  /// Returns the value as-is since we always work in Celsius internally.
  double toCelsius() => value;

  /// Converts the temperature to Fahrenheit.
  double toFahrenheit() => (value * 9 / 5) + 32;

  /// Converts the temperature to Kelvin.
  double toKelvin() => value + 273.15;

  /// Returns the temperature in the original unit from the device.
  double toOriginalUnit() {
    switch (originalUnit) {
      case TemperatureUnit.celsius:
        return value;
      case TemperatureUnit.fahrenheit:
        return toFahrenheit();
    }
  }

  @override
  String toString() {
    return 'TemperatureReading(value: ${value.toStringAsFixed(1)}°C, '
           'originalUnit: $originalUnit, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TemperatureReading &&
        other.value == value &&
        other.originalUnit == originalUnit &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(value, originalUnit, timestamp);
}

/// Temperature units supported by the Ray Temp Blue device.
enum TemperatureUnit {
  /// Celsius (°C)
  celsius,
  
  /// Fahrenheit (°F)
  fahrenheit,
}

/// Extension to provide display names for temperature units.
extension TemperatureUnitExtension on TemperatureUnit {
  /// Returns the display symbol for the temperature unit.
  String get symbol {
    switch (this) {
      case TemperatureUnit.celsius:
        return '°C';
      case TemperatureUnit.fahrenheit:
        return '°F';
    }
  }

  /// Returns the display name for the temperature unit.
  String get displayName {
    switch (this) {
      case TemperatureUnit.celsius:
        return 'Celsius';
      case TemperatureUnit.fahrenheit:
        return 'Fahrenheit';
    }
  }
}
